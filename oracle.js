Let express = require('express');
Let seedrandom = require('seedrandom');
//we are importing these libraries for creating the server and generating the seed
const fs = require('fs');
let app = express();
let web3 = new Web3('https://mainnet.infura.io.......we connect to our provider for ethereum main net using the end point');
let contractAddress = 'our contract address will go in here ';
//we are reading the contents of our file seed.txt which we can also change ourselves so we can control the randomness
let rng = seedrandom(fs.readFileSync( path: 'seed.txt', options: (encoding: utf8', flag: 'r^}));
//these variables will hold our seed parameters
let acc, c, mod, curr;
function setupSeedParams() {
    //assigning some values to our parameters 
curr = Math.trunc(x: rng()* 12454);
acc = 151;
mod 76564353456678978687;
c = 4567;
}
function randomNumber() { curr = ((curr acc) + c) % mod;
return curr;

//we are initializing the parameters before the server starts and we are using an api endpoint './random'

app.get('/random', function (req, res) {
    let randomNum = randomNumber();
    // Send the random number to the smart contract
    contract.methods.setRandomNumber(randomNum).send({ from: '<your_sender_address>' })
        .then(function (result) {
            res.send(randomNum.toString());
        })
        .catch(function (error) {
            res.status(500).send('Error sending random number to the smart contract');
        });
});
app.listen(3000, function () 
setupSeedParams();)
});