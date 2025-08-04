require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const { MongoClient } = require('mongodb');
const cors = require("cors");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const nodemailer = require('nodemailer');
const app = express();
app.use(express.json());
app.use(cors());
const secretKey = "sukeshpavanjayakrishnanarasaredd"; 
const algorithm = "aes-256-cbc";
function encryptPassword(password) {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(algorithm, Buffer.from(secretKey), iv);
  let encrypted = cipher.update(password, "utf8", "hex");
  encrypted += cipher.final("hex");
  return iv.toString("hex") + ":" + encrypted; 
}
function decryptPassword(encryptedText) {
  try {
    const [ivHex, encryptedData] = encryptedText.split(":");
    const iv = Buffer.from(ivHex, "hex");
    const decipher = crypto.createDecipheriv(algorithm, Buffer.from(secretKey), iv);
    let decrypted = decipher.update(encryptedData, "hex", "utf8");
    decrypted += decipher.final("utf8");
    return decrypted;
  } catch (err) {
    console.error("Decryption error:", err);
    return null;
  }
}
mongoose.connect("mongodb+srv://sukesh31:sukesh2006@cluster0.41zgf.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log("Connected to MongoDB"))
.catch((err) => console.error("MongoDB Connection Error:", err));

app.get("/", (req, res) => {
  res.send("Status Hub API is running successfully.");
});

const UserSchema = new mongoose.Schema({
  name: {type:String,required:true},
  gender: { type: String, required:true },
  address:{type:String,required:true},
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true }
});
const User = mongoose.model("User", UserSchema);
app.post("/api/auth/register", async (req, res) => {
  try {
    const {name,gender,address, email, password } = req.body;
    if (!name||!gender||!address||!email || !password) {
      return res.status(400).json({ message: "Email and password are required" });
    }
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }
    const encryptedPassword = encryptPassword(password);
    const newUser = new User({ name,gender,address,email, password: encryptedPassword });
    await newUser.save();
    res.status(201).json({ message: "User registered successfully!" });
  } catch (error) {
    console.error("Error registering user:", error);
    res.status(500).json({ message: "Server error" });
  }
});


app.get('/api/users/email/:email', async (req, res) => {
  try {
    const user = await User.findOne({ email: req.params.email });
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Return only non-sensitive data
    res.json({
      _id: user._id,
      name: user.name,
      email: user.email,
      password: user.password,
      gender: user.gender,
      address: user.address
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Update user
app.put('/api/users/:id', async (req, res) => {
  try {
    const { name, gender, address } = req.body;
    
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      { name, gender, address },
      { new: true }
    );
    
    if (!updatedUser) return res.status(404).json({ message: 'User not found' });
    
    res.json({
      _id: updatedUser._id,
      name: updatedUser.name,
      email: updatedUser.email,
      gender: updatedUser.gender,
      address: updatedUser.address
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});
app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: "Email and password are required" });
    }
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ error: "User not found" });
    }
    const decryptedPassword = decryptPassword(user.password);
    if (!decryptedPassword || password !== decryptedPassword) {
      return res.status(400).json({ error: "Invalid credentials" });
    }
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || "secret",
      { expiresIn: "1h" }
    );
    res.json({ token,
      email: user.email,
     });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Server error" });
  }
});

const otpStore = {}; 
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "vemurisukesh31012006@gmail.com", 
    pass: "wcxv htzt ekck agjj", 
  },
});
app.post("/send-otp", async (req, res) => {
  const { email } = req.body;
  const user = await User.findOne({ email });
  if (!user) return res.status(404).json({ message: "User not found" });
  const otp = Math.floor(100000 + Math.random() * 900000).toString(); 
  otpStore[email] = otp;
  const mailOptions = {
    from: "vemurisukesh31012006@gmail.com",
    to: email,
    subject: "Your OTP Code",
    text: `Use ${otp} as your one-time code to proceed. This code is valid for 10 minutes. Thank you for using StatusHub!`,
  };
  transporter.sendMail(mailOptions, (error, info) => {
    if (error) return res.status(500).json({ message: "Error sending email" });
    res.json({ message: "OTP sent successfully" });
  });
});
app.post("/verify-otp", (req, res) => {
  const { email, otp } = req.body;
  if (otpStore[email] && otpStore[email] === otp) {
    delete otpStore[email]; 
    res.json({ message: "OTP verified successfully" });
  } else {
    res.status(400).json({ message: "Invalid or expired OTP" });
  }
});
app.post("/reset-password", async (req, res) => {
  const { email, newPassword } = req.body;
  const encryptedPassword = encryptPassword(newPassword);
  const user = await User.findOneAndUpdate(
    { email },
    { password: encryptedPassword},
    { new: true }
  );
  if (!user) return res.status(404).json({ message: "User not found" });
  res.json({ message: "Password reset successfully" });
});

const OwnerSchema = new mongoose.Schema({
  name: String,
  shopname: String,
  address: String,
  category: String,
  phone:String,
  username: { type: String, unique: true, required: true },
  password: String,
  latitude: String,
  longitude: String,
  status: { type: String, default: "closed" } // Default status is 'closed'
});
const Owner = mongoose.model("Owner", OwnerSchema);
app.get("/owner/:username", async (req, res) => {
  try {
    const owner = await Owner.findOne({ username: req.params.username });
    if (!owner) {
      return res.status(404).json({ message: "Owner not found" });
    }
    res.json({ name: owner.name, shopname: owner.shopname });
  } catch (error) {
    console.error("Error fetching owner details:", error);
    res.status(500).json({ message: "Server error" });
  }
});
app.get("/shop-status/:username", async (req, res) => {
  try {
    const owner = await Owner.findOne({ username: req.params.username });
    if (!owner) {
      return res.status(404).json({ message: "Shop not found" });
    }
    res.json({ status: owner.status });
  } catch (error) {
    console.error("Error fetching shop status:", error);
    res.status(500).json({ message: "Server error" });
  }
});
app.post("/update-status", async (req, res) => {
  try {
    const { username, status } = req.body;
    if (!username || !status) {
      return res.status(400).json({ message: "Username and status are required" });
    }
    const owner = await Owner.findOne({ username });
    if (!owner) {
      return res.status(404).json({ message: "Owner not found" });
    }
    owner.status = status;
    await owner.save();
    res.json({ message: "Status updated successfully", status });
  } catch (error) {
    console.error("Error updating shop status:", error);
    res.status(500).json({ message: "Server error" });
  }
});
app.post("/register-owner", async (req, res) => {
  try {
    console.log("Received registration request:", req.body);
    const { name,shopname,address,category,phone,username, password ,latitude,longitude} = req.body;
    if (!name||!shopname||!address||!phone||!username || !password||!latitude||!longitude) {
      return res.status(400).json({ message: "All details are required" });
    }
    const existingUser = await Owner.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ message: "Owner already exists" });
    }
    const encryptedPassword = encryptPassword(password);
    const newOwner = new Owner({ name,shopname,address,category,phone,username, password: encryptedPassword,latitude,longitude});
    await newOwner.save();
    console.log("Owner registered:", username);
    res.status(201).json({ message: "Owner registered successfully!" });
  } catch (error) {
    console.error("Error registering Owner:", error);
    res.status(500).json({ message: "Server error" });
  }
});
app.post("/owner-login", async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({ error: "Username and password are required" });
    }
    const user = await Owner.findOne({ username });
    if (!user) {
      return res.status(400).json({ error: "Owner not found" });
    }
    const decryptedPassword = decryptPassword(user.password);
    if (!decryptedPassword || password !== decryptedPassword) {
      return res.status(400).json({ error: "Invalid credentials" });
    }
    if (!user.shopname) {
      console.error("Error: shopname is missing for this owner!");
      return res.status(400).json({ error: "Shop name is missing for this owner" });
    }
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || "secret",
      { expiresIn: "1h" }
    );
    res.json({
      token,
      username: user.username,
      shopname: user.shopname,  
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Server error" });
  }
});


// Get distinct categories for filter options
app.get('/get-categories', async (req, res) => {
  try {
    const categories = await Owner.distinct('category');
    res.json(categories);
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ message: 'Failed to fetch categories' });
  }
});
app.get('/api/shops/:username', async (req, res) => {
  try {
    const shop = await Owner.findOne(
      { username: req.params.username },
      { _id: 0, __v: 0, password: 0 }
    );
    
    if (!shop) {
      return res.status(404).json({
        success: false,
        message: 'Shop not found'
      });
    }
    
    res.json({
      success: true,
      shop
    });
  } catch (error) {
    console.error('Error fetching shop details:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch shop details'
    });
  }
});
const AdminSchema = new mongoose.Schema({
  name:String,
  address:String,
  username: String,
  password: String
});
const Admin = mongoose.model('Admin', AdminSchema);
app.post("/admin-login", async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({ error: "Username and password are required" });
    }
    const admin = await Admin.findOne({ username });
    if (!admin) {
      return res.status(400).json({ error: "Admin not found" });
    }
    const decryptedPassword = decryptPassword(admin.password);
    if (!decryptedPassword || password !== decryptedPassword) {
      return res.status(400).json({ error: "Invalid credentials" });
    }
    const token = jwt.sign({ adminId: admin._id }, process.env.JWT_SECRET || "secret", { expiresIn: "1h" });
    res.json({ token });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Server error" });
  }
});
app.post("/register-admin", async (req, res) => {
  try {
    console.log("Received registration request:", req.body);
    const { name,address,username, password } = req.body;
    if (!name||!address||!username || !password) {
      return res.status(400).json({ message: "All details are required" });
    }
    const existingUser = await Admin.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ message: "Owner already exists" });
    }
    const encryptedPassword = encryptPassword(password);
    const newAdmin = new Admin({ name,address,username, password: encryptedPassword });
    await newAdmin.save();
    console.log("Admin registered:", username);
    res.status(201).json({ message: "Admin registered successfully!" });
  } catch (error) {
    console.error("Error registering Admin:", error);
    res.status(500).json({ message: "Server error" });
  }
});
const SuperAdminSchema = new mongoose.Schema({
  username: String,
  password: String
});
const SuperAdmin = mongoose.model('SuperAdmin', SuperAdminSchema);
app.post("/superadminlogin", async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({ error: "Username and password are required" });
    }
    const superadmin = await SuperAdmin.findOne({ username });
    if (!superadmin) {
      return res.status(400).json({ error: "Super Admin not found" });
    }
    const isMatch = password === superadmin.password; 
    if (!isMatch) {
      return res.status(400).json({ error: "Invalid credentials" });
    }
    const token = jwt.sign({ adminId: superadmin._id }, process.env.JWT_SECRET || "secret", { expiresIn: "1h" });
    res.json({ token });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Server error" });
  }
});
app.get("/get-users", async (req, res) => {
  try {
    const users = await User.find({}, { __v: 0 }); 
    res.json(users);
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ message: "Server error" });
  }
});
app.get("/get-owners", async (req, res) => {
  try {
    const owners = await Owner.find({}, { __v: 0 }); 
    res.json(owners);
  } catch (error) {
    console.error("Error fetching owners:", error);
    res.status(500).json({ message: "Server error" });
  }
});
app.get("/get-admins", async (req, res) => {
  try {
    const admins = await Admin.find({}, { __v: 0 }); 
    res.json(admins);
  } catch (error) {
    console.error("Error fetching admins:", error);
    res.status(500).json({ message: "Server error" });
  }
});
app.get('/search', async (req, res) => {
  try {
    const { shopname, email, username } = req.query;
    let results;
    if (shopname) {
      results = await Owner.find({
        shopname: { $regex: shopname, $options: 'i' }, 
      });
    } else if (email) {
      results = await User.find({
        email: { $regex: email, $options: 'i' }, 
      });
    } else if (username) {
      results = await Admin.find({
        username: { $regex: username, $options: 'i' }, 
      });
    } else {
      return res.status(400).json({ message: 'Invalid search query' });
    }
    res.json(results);
  } catch (err) {
    console.error('Search error:', err);
    res.status(500).json({ message: 'Server Error' });
  }
});
app.delete("/delete-owner/:username", async (req, res) => {
  try {
    const { username } = req.params;
    if (!username) {
      return res.status(400).json({ message: "Username is required" });
    }
    const deletedOwner = await Owner.findOneAndDelete({ username });
    if (!deletedOwner) {
      return res.status(404).json({ message: "Owner not found" });
    }
    res.status(200).json({ message: "Owner deleted successfully" });
  } catch (error) {
    console.error("Error deleting owner:", error);
    res.status(500).json({ message: "Server error" });
  }
});
app.put("/update-owner/:username", async (req, res) => {
  try {
    const { username } = req.params;
    const updatedData = req.body;
    if (!username) {
      return res.status(400).json({ message: "Username is required" });
    }
    const updatedOwner = await Owner.findOneAndUpdate(
      { username }, 
      updatedData,  
      { new: true } 
    );
    if (!updatedOwner) {
      return res.status(404).json({ message: "Owner not found" });
    }
    res.status(200).json({ message: "Owner updated successfully", owner: updatedOwner });
  } catch (error) {
    console.error("Error updating owner:", error);
    res.status(500).json({ message: "Server error" });
  }
});
app.delete("/delete-admin/:username", async (req, res) => {
  try {
    const { username } = req.params;
    if (!username) {
      return res.status(400).json({ message: "Username is required" });
    }
    const deletedAdmin = await Admin.findOneAndDelete({ username });
    if (!deletedAdmin) {
      return res.status(404).json({ message: "Admin not found" });
    }
    res.status(200).json({ message: "Admin deleted successfully" });
  } catch (error) {
    console.error("Error deleting admin:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});
app.put("/update-admin/:username", async (req, res) => {
  try {
    const { username } = req.params;
    const updatedData = req.body;
    if (!username) {
      return res.status(400).json({ message: "Username is required" });
    }
    const updatedAdmin = await Admin.findOneAndUpdate(
      { username }, 
      updatedData, 
      { new: true } 
    );
    if (!updatedAdmin) {
      return res.status(404).json({ message: "Admin not found" });
    }
    const adminResponse = updatedAdmin.toObject();
    delete adminResponse.password;
    res.status(200).json({ message: "Admin updated successfully", admin: adminResponse });
  } catch (error) {
    console.error("Error updating admin:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});
app.delete("/delete-user/:email", async (req, res) => {
  try {
    const { email } = req.params;
    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }
    const deletedUser = await User.findOneAndDelete({ email });
    if (!deletedUser) {
      return res.status(404).json({ message: "User not found" });
    }
    res.status(200).json({ message: "User deleted successfully" });
  } catch (error) {
    console.error("Error deleting user:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});
app.put("/update-user/:email", async (req, res) => {
  try {
    const { email } = req.params;
    const updatedData = req.body;
    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }
    const updatedUser = await User.findOneAndUpdate(
      { email }, 
      updatedData, 
      { new: true } 
    );
    if (!updatedUser) {
      return res.status(404).json({ message: "User not found" });
    }
    const userResponse = {
      email: updatedUser.email,
    };
    res.status(200).json({ message: "User updated successfully", user: userResponse });
  } catch (error) {
    console.error("Error updating user:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});
const PORT = process.env.PORT || 5002;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));