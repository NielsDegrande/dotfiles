// Source: https://codeberg.org/librewolf/settings/src/branch/master/librewolf.cfg.

// Turn off fingerprinting resistance to allow smooth scrolling.
user_pref("privacy.resistFingerprinting", false);
user_pref("general.smoothScroll", true);

// Avoid autoplay, disable sticky.
user_pref("media.autoplay.blocking_policy", 2);

// Enable WebGL.
user_pref("webgl.disabled", false);
