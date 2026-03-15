const FORBIDDEN_EVENT = "app:forbidden-change";

let forbiddenVisible = false;

const notifyForbiddenChange = () => {
  if (typeof window === "undefined") {
    return;
  }

  window.dispatchEvent(
    new CustomEvent(FORBIDDEN_EVENT, {
      detail: forbiddenVisible,
    })
  );
};

export const showForbiddenPage = () => {
  if (forbiddenVisible) {
    return;
  }

  forbiddenVisible = true;
  notifyForbiddenChange();
};

export const hideForbiddenPage = () => {
  if (!forbiddenVisible) {
    return;
  }

  forbiddenVisible = false;
  notifyForbiddenChange();
};

export const isForbiddenVisible = () => forbiddenVisible;

export const subscribeToForbiddenPage = (callback) => {
  if (typeof window === "undefined") {
    return () => {};
  }

  const handler = (event) => {
    callback(Boolean(event.detail));
  };

  window.addEventListener(FORBIDDEN_EVENT, handler);

  return () => {
    window.removeEventListener(FORBIDDEN_EVENT, handler);
  };
};