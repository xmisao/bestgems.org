function initGemAutocomplete() {
  const searchInput = document.getElementById('gem-search');
  const resultsContainer = document.getElementById('autocomplete-results');
  const form = searchInput.closest('form');
  let searchTimeout;

  searchInput.addEventListener('input', function() {
    const query = this.value.trim();
    clearTimeout(searchTimeout);
    
    if (query.length < 2) {
      resultsContainer.innerHTML = '';
      resultsContainer.style.display = 'none';
      return;
    }

    searchTimeout = setTimeout(() => {
      fetch(`/api/v1/gems/autocomplete.json?q=${encodeURIComponent(query)}`)
        .then(response => response.json())
        .then(gems => {
          resultsContainer.innerHTML = '';
          if (gems.length === 0) {
            resultsContainer.style.display = 'none';
            return;
          }

          gems.forEach(gem => {
            const div = document.createElement('div');
            div.className = 'autocomplete-item';
            div.innerHTML = `<strong>${gem.name}</strong><div class="gem-summary">${gem.summary || 'No description'}</div>`;
            div.addEventListener('click', function() {
              searchInput.value = gem.name;
              resultsContainer.style.display = 'none';
              form.submit();
            });
            resultsContainer.appendChild(div);
          });
          resultsContainer.style.display = 'block';
        })
        .catch(() => {
          resultsContainer.innerHTML = '';
          resultsContainer.style.display = 'none';
        });
    }, 300);
  });

  document.addEventListener('click', function(event) {
    if (!searchInput.contains(event.target) && !resultsContainer.contains(event.target)) {
      resultsContainer.style.display = 'none';
    }
  });
}