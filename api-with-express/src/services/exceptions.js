class MissingResourceError extends Error {
  constructor(data) {
    super();
    this.data = data;
  }
}

class ValidationError extends Error {
  constructor(data) {
    super();
    this.data = data;
  }
}

class NoDataError extends Error {
  constructor(data) {
    super();
    this.data = data;
  }
}

class AuthError extends Error {
  constructor(data) {
    super();
    this.data = data;
  }
}

module.exports = {
  MissingResourceError,
  ValidationError,
  NoDataError,
  AuthError
};
