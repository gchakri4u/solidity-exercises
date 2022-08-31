var CountManager = artifacts.require("./CountManager.sol");


module.exports = function(deployer) {  
  deployer.deploy(CountManager);
};