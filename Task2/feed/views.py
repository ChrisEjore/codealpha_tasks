from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib.auth import login, logout
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib import messages
from .models import Post, Comment, User, Follower

def register_view(request):
    if request.user.is_authenticated:
        return redirect('index')

    if request.method == 'POST':
        form = UserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            messages.success(request, "Welcome to Beatz!")
            return redirect('index')
    else:
        form = UserCreationForm()

    return render(request, 'feed/register.html', {'form': form})
def login_view(request):
    if request.user.is_authenticated:
        return redirect('index')

    if request.method == 'POST':
        form = AuthenticationForm(request, data=request.POST) # Pass request object as first argument
        if form.is_valid():
            user = form.get_user()
            login(request, user)
            return redirect('index')
        else:
            messages.error(request, "Invalid username or password.")
    else:
        form = AuthenticationForm()

    return render(request, 'feed/login.html', {'form': form})
def logout_view(request):
    logout(request)
    return redirect('login')


def index(request):
    if request.method == 'POST':
        if not request.user.is_authenticated:
            return redirect('login')
        content = request.POST.get('content', '').strip()
        if content:
            Post.objects.create(author=request.user, content=content)
        return redirect('index')

    posts = Post.objects.all().select_related('author').prefetch_related('likes', 'comments__author')
    return render(request, 'feed/index.html', {'posts': posts})

@login_required
def toggle_like(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    if request.user in post.likes.all():
        post.likes.remove(request.user)
    else:
        post.likes.add(request.user)
    return redirect(request.META.get('HTTP_REFERER', 'index'))

@login_required
def add_comment(request, post_id):
    if request.method == 'POST':
        post = get_object_or_404(Post, id=post_id)
        content = request.POST.get('content', '').strip()
        if content:
            Comment.objects.create(post=post, author=request.user, content=content)
    return redirect(request.META.get('HTTP_REFERER', 'index'))

# --- USER PROFILE & FOLLOW SYSTEM ---

def profile_view(request, username):
    profile_user = get_object_or_404(User, username=username)
    user_posts = profile_user.posts.all().select_related('author').prefetch_related('likes', 'comments__author')

    # Check if logged in user is following this profile
    is_following = False
    if request.user.is_authenticated and request.user != profile_user:
        is_following = Follower.objects.filter(follower=request.user, following=profile_user).exists()

    followers_count = profile_user.rel_followers.count()
    following_count = profile_user.rel_following.count()

    context = {
        'profile_user': profile_user,
        'posts': user_posts,
        'is_following': is_following,
        'followers_count': followers_count,
        'following_count': following_count,
    }
    return render(request, 'feed/profile.html', context)

@login_required
def toggle_follow(request, username):
    target_user = get_object_or_404(User, username=username)
    if request.user != target_user:
        follow_rel, created = Follower.objects.get_or_create(follower=request.user, following=target_user)
        if not created:
            follow_rel.delete()
    return redirect('profile', username=username)