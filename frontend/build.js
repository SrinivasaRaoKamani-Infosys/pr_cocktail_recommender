const fs = require("fs");

const html = `
<!DOCTYPE html>
<html>
<head>
<title>React Frontend</title>
</head>
<body>
<h1>React Frontend</h1>
<button onclick="callApi()">Call Backend</button>
<p id="result"></p>

<script>
function callApi() {
fetch('/api/message')
.then(res => res.json())
.then(data => {
document.getElementById('result').innerText = data.message;
})
.catch(err => {
document.getElementById('result').innerText = 'Error calling backend';
});
}
</script>
</body>
</html>
`;

fs.mkdirSync("build", { recursive: true });
fs.writeFileSync("build/index.html", html);
