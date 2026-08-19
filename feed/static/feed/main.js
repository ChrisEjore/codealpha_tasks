document.addEventListener("DOMContentLoaded", () => {
    const submitBtn = document.getElementById("submitPostBtn");
    const postContent = document.getElementById("postContent");
    const postsContainer = document.getElementById("postsContainer");

    // Dummy initial state to satisfy JS requirements
    const samplePosts = [
        { author: "@ejore", content: "Testing the new Beatz web interface!", likes: 3 }
    ];

    function renderPosts() {
        postsContainer.innerHTML = "";
        samplePosts.forEach(post => {
            const postEl = document.createElement("div");
            postEl.className = "card";
            postEl.innerHTML = `
                <div class="post-header">${post.author}</div>
                <div>${post.content}</div>
                <div class="actions">
                    <span class="action-btn">❤️ ${post.likes} Likes</span>
                    <span class="action-btn">💬 Comment</span>
                </div>
            `;
            postsContainer.appendChild(postEl);
        });
    }

    submitBtn.addEventListener("click", () => {
        const text = postContent.value.trim();
        if (text) {
            samplePosts.unshift({ author: "@you", content: text, likes: 0 });
            postContent.value = "";
            renderPosts();
        }
    });

    renderPosts();
});