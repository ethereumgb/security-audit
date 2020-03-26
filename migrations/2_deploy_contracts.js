const BadKickback = artifacts.require("BadKickback");

module.exports = function(deployer) {
  deployer.deploy(BadKickback);
};
