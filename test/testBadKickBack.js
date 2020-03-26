const BadKickBack = artifacts.require('BadKickback');
const BN = require('bn.js');

contract("BadKickback", accounts => {
   let kickback;
   const fee = web3.utils.toWei('1', 'ether');

   before(() => {
      return BadKickBack.deployed().then(instance => {
         kickback = instance;
      });
   });

   it("should be able to participate in the event", async () => {
      const participants =  accounts.slice(0, 4);
      const promises = participants
                         .map(from => kickback.participate({value: fee, from}));
      const results = await Promise.all(promises);
      for(let i = 0; i < results.length; i++ ) {
         assert.equal(results[i].receipt.status, true, "tx failed");
      }
   });

   it("should be able to payout to attendees", async () => {
      const balance = await web3.eth.getBalance(accounts[1])
      const attendees = [accounts[1]];
      const tx = await kickback.payout(attendees);
      assert.equal(tx.receipt.status, true, "tx failed");

      // check that account1 receives 4 ethers from the payout
      const newBalance = await web3.eth.getBalance(accounts[1])
      const fourEther = web3.utils.toWei('4', 'ether');
      const balanceDifference = new BN(newBalance).sub(new BN(balance));
      assert.equal(balanceDifference, fourEther, "newBalance should be more");
   });

});
