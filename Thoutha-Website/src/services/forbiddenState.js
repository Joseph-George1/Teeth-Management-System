let forbiddenVisible = false;
const listeners = new Set();

const notifyForbiddenChange = () => {
  listeners.forEach((listener) => listener());
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
  listeners.add(callback);

  return () => {
    listeners.delete(callback);
  };
};