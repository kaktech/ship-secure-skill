// Deliberately vulnerable Express app. Do not run in production.
const express = require("express");
const crypto = require("crypto");
const multer = require("multer");
const db = require("mysql").createConnection({});
const app = express();
app.use(express.json());
const upload = multer({ dest: "public/uploads/" });           // item 16: no limits, public dir, original names

app.post("/api/register", (req, res) => {
  const hash = crypto.createHash("md5").update(req.body.password).digest("hex"); // item 10
  db.query("INSERT INTO users SET ?", { ...req.body, password: hash });          // item 8: mass assignment (role, isAdmin)
  res.cookie("sid", "abc123");                                                    // item 9: no HttpOnly/Secure/SameSite
  res.json({ ok: true });
});

app.post("/api/login", (req, res) => {                                            // item 11: no rate limit
  db.query(`SELECT * FROM users WHERE email = '${req.body.email}'`, (e, rows) => { // item 13: SQLi
    res.json(rows[0]);                                                             // item 17: full row incl. hash
  });
});

app.get("/api/notes/:id", (req, res) => {                                         // items 6/7: no auth, no owner check
  db.query("SELECT * FROM notes WHERE id = " + req.params.id, (e, rows) => res.json(rows[0]));
});

app.post("/api/upload", upload.single("file"), (req, res) => res.json({ path: req.file.path, name: req.file.originalname }));

app.listen(3000);
