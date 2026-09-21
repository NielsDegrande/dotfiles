// Enable Ctrl+Tab to switch tabs by most recently used order.
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);

// Disable borders.
user_pref("zen.theme.content-element-separation", 0);

// Speculative loading, matches Chrome's behaviour.
user_pref("network.prefetch-next", true);
user_pref("network.dns.disablePrefetch", false);
user_pref("network.http.speculative-parallel-limit", 6);
user_pref("browser.urlbar.speculativeConnect.enabled", true);

// Write session state every 60s instead of 15s.
user_pref("browser.sessionstore.interval", 60000);

// Kill UI transitions (affects Zen's sidebar, glance and tab animations).
user_pref("ui.prefersReducedMotion", 1);

// Disable the translucent blur in Zen's toolbar and sidebar.
user_pref("zen.theme.acrylic-elements", false);
