var interceptor = document.createElement("script");
interceptor.src = chrome.runtime.getURL("content/interceptor.js");

interceptor.onload = () => {
  // this.remove();
  console.log("[*] Interceptor loaded");
};

var doc = document.head || document.documentElement;
doc.appendChild(interceptor);

// eslint-disable-next-line no-undef
withActiveSites((activeSites) => {
  window.addEventListener(
    "message",
    (event) => {
      const { origin } = event;

      const matchingOrigins = activeSites.filter((site) =>
        origin.includes(site)
      );

      if (matchingOrigins.length > 0) {
        const { data } = event;

        if (data.type === "interceptedMessage") {
          chrome.runtime.sendMessage(data);
        }
      }
    },
    false
  );
});
