var BiddingNFT = artifacts.require("./BiddingNFT.sol");


module.exports = function(deployer) {  
  deployer.deploy(BiddingNFT);
};