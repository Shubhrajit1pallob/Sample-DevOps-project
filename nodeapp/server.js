import express from 'express';

const app = express();
const port = 3000;

app.get('/', (req, res) => {
    res.send("Hello, World! This is a Node.js application running on AWS EC2 with Terraform.");
})

app.listen(port, () => {
    console.log(`Server is running on port ${port}`)
})