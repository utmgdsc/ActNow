import 'core-js/stable';
import 'regenerator-runtime/runtime';
import express from 'express';

const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});

// you can remove the things below later
const test = async () => {
  return 1;
};

const test2 = async () => {
  const res = await test();
  console.log(res);
};

test2();
