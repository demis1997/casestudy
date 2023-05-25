//linear congruential generator
//even though we are taking a seed file and using an advanced formula while also not using block hash and blocktimestamp, there are a limited amount of variations we can have 

const express = require('express');
const seedrandom = require('seedrandom');
const fs = require('fs');
const Web3 = require('web3');

const app = express();
const web3 = new Web3('connect to web3 api'); 
const contractAddress = 'our casestudymint contract'; 

let rng;

// Read the contents of the seed file and initialize the RNG
fs.readFile('seed.txt', 'utf8', (err, data) => {
  if (err) {
    console.error('Error reading seed file:', err);
    process.exit(1);
  }
  rng = seedrandom(data);
  setupSeedParams();
  app.listen(3000, () => {
    console.log('Server started on port 3000');
  });
});

let acc, c, mod, curr;

function setupSeedParams() {
  curr = Math.trunc(rng() * 12454);
  acc = 151;
  mod = 76564353456678978687;
  c = 4567;
}

function randomNumber() {
  curr = (curr * acc + c) % mod;
  return curr;
}

app.get('/random', (req, res) => {
  const randomNum = randomNumber();
  contract.methods
    .setRandomNumber(randomNum)
    .send({ from: '<your_sender_address>' })
    .then((result) => {
      res.send(randomNum.toString());
    })
    .catch((error) => {
      res.status(500).send('Error sending random number to the smart contract');
    });
});
