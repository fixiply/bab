class ClassHelper {

  static bool hasStatus(dynamic d) {
    try {
      d.status;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool hasImage(dynamic d) {
    try {
      d.image;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool hasImages(dynamic d) {
    try {
      d.images;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool hasStartAt(dynamic d) {
    try {
      d.start_at;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool hasEndAt(dynamic d) {
    try {
      d.end_at;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool hasBooking(dynamic d) {
    try {
      d.booking;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool hasLayout(dynamic d) {
    try {
      d.layout;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool hasProducts(dynamic d) {
    try {
      d.products;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool hasRecipient(dynamic d) {
    try {
      d.recipient;
      return true;
    } catch (e) {
      return false;
    }
  }
}
