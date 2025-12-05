const User = require('../models/User');

class UserRepository {
  async findByEmail(email) {
    try {
      return await User.findOne({ email: email.toLowerCase() });
    } catch (error) {
      throw error;
    }
  }

  async findById(id) {
    try {
      return await User.findById(id);
    } catch (error) {
      throw error;
    }
  }

  async create(userData) {
    try {
      const user = new User(userData);
      return await user.save();
    } catch (error) {
      throw error;
    }
  }

  async update(id, updates) {
    try {
      return await User.findByIdAndUpdate(
        id,
        { $set: updates },
        { new: true, runValidators: true }
      );
    } catch (error) {
      throw error;
    }
  }

  async delete(id) {
    try {
      return await User.findByIdAndDelete(id);
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new UserRepository();


