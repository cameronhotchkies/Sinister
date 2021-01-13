// eslint-disable-next-line no-unused-vars
const withActiveSites = (handler) => {
  chrome.storage.sync.get("activeSites", (dataset) => {
    var existingSites;
    const { activeSites } = dataset;
    try {
      const parsed = JSON.parse(activeSites);

      if (Array.isArray(parsed)) {
        existingSites = parsed;
      }

      if (!existingSites) {
        existingSites = [];
      }
    } catch (ignored) {
      existingSites = [];
    }

    handler(existingSites);
  });
};
