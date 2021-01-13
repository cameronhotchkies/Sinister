const removeSite = (siteToRemove) => () => {
  // eslint-disable-next-line no-undef
  withActiveSites((existingSites) => {
    const updated = existingSites.filter((site) => site !== siteToRemove);

    chrome.storage.sync.set(
      { activeSites: JSON.stringify(updated) },
      restoreOptions
    );
  });
};

// Saves options to chrome.storage
function saveSite() {
  const newSiteInput = document.getElementById("new-site");
  const newSite = newSiteInput.value;

  // Append, not replace
  // eslint-disable-next-line no-undef
  withActiveSites((previous) => {
    const updatedSites = previous.concat([newSite]);
    chrome.storage.sync.set(
      {
        activeSites: JSON.stringify(updatedSites),
      },
      () => {
        restoreOptions();
        // Update status to let user know options were saved.
        var status = document.getElementById("status");

        status.textContent = "Options saved.";
        newSiteInput.value = "";
        setTimeout(() => {
          status.textContent = "";
        }, 750);
      }
    );
  });
}

// Restores select box and checkbox state using the preferences
// stored in chrome.storage.
function restoreOptions() {
  // eslint-disable-next-line no-undef
  withActiveSites((activeSites) => {
    const enabledSiteList = document.getElementById("enabled-sites");

    enabledSiteList.innerHTML = "";

    activeSites.forEach((site) => {
      const listItem = document.createElement("li");
      const removal = document.createElement("button");
      removal.onclick = removeSite(site);
      removal.innerHTML = "X";

      listItem.innerHTML = `${site} `;
      listItem.appendChild(removal);

      enabledSiteList.appendChild(listItem);
    });
  });
}
document.addEventListener("DOMContentLoaded", restoreOptions);
document.getElementById("add").addEventListener("click", saveSite);
