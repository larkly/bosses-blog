/* App JS — theme toggle + small niceties.
   Site styling lives in css/styles.css (copied from the mockup). */
(function() {
  const root = document.documentElement;
  const btn = document.getElementById('theme-toggle');

  function effective() {
    const set = root.getAttribute('data-theme');
    if (set === 'light' || set === 'dark') return set;
    return matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }
  function paint() { if (btn) btn.textContent = effective() === 'dark' ? '☾' : '☀'; }
  paint();

  if (btn) {
    btn.addEventListener('click', function() {
      const cur = root.getAttribute('data-theme') || 'auto';
      const next = cur === 'light' ? 'dark' : cur === 'dark' ? 'auto' : 'light';
      if (next === 'auto') root.removeAttribute('data-theme');
      else root.setAttribute('data-theme', next);
      try { localStorage.setItem('lantern.theme', next); } catch(e) {}
      paint();
    });
  }

  matchMedia('(prefers-color-scheme: dark)').addEventListener('change', paint);

  // Mobile nav toggle
  const navBtn = document.getElementById('nav-toggle');
  const nav = document.getElementById('site-nav');
  if (navBtn && nav) {
    navBtn.addEventListener('click', function() {
      const open = nav.classList.toggle('is-open');
      navBtn.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
    nav.querySelectorAll('a').forEach(a => {
      a.addEventListener('click', () => {
        nav.classList.remove('is-open');
        navBtn.setAttribute('aria-expanded', 'false');
      });
    });
  }

  // Copy-link share button on posts
  document.querySelectorAll('[data-copy-link]').forEach(a => {
    a.addEventListener('click', e => {
      e.preventDefault();
      navigator.clipboard?.writeText(location.href);
      const t = a.textContent;
      a.textContent = 'Copied';
      setTimeout(() => a.textContent = t, 1400);
    });
  });

  // TOC scroll-spy (cheap)
  const toc = document.querySelector('.toc');
  if (toc) {
    const links = toc.querySelectorAll('a[href^="#"]');
    const targets = Array.from(links).map(a => document.getElementById(decodeURIComponent(a.getAttribute('href').slice(1)))).filter(Boolean);
    function spy() {
      const y = scrollY + 120;
      let active = targets[0];
      for (const t of targets) if (t.offsetTop <= y) active = t;
      links.forEach(a => a.parentElement.classList.toggle('is-active', a.getAttribute('href') === '#' + active?.id));
    }
    addEventListener('scroll', spy, { passive: true });
    spy();
  }
})();
