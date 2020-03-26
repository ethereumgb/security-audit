pragma solidity ^0.5.0;


/* This is a bad simulation of https://kickback.events
 * Contract has been made intentionally with vulnerablity for learning purpose
 * DO NOT USE THIS contract
 *
 * The contract aims at producing higher event turnup rate
 * by charging an admission fee and then
 * split the collected fund with all attendees
 * No-shows will lose their admission fee
 * 
*/
contract BadKickback {

    // maximum number of participants accepted
    uint public cap = 50;
    
    // fee to participate in the event
    uint public fee = 1 ether;
    
    // owner of this contract; admin for the event
    address payable public owner = msg.sender;

    // participants who contributed to the fund
    mapping(address=>bool) public participants;
    
    // total number of participants
    uint public participantCount;

    // participate the event and pay fee
    function participate() public payable {
        require(msg.value == fee, "must pay exact fee");
        require(participantCount < cap, "this event is closed");
        participants[msg.sender] = true;
        participantCount++;
    }
    
    // at the end of the event, split the fund and pay to everyone who attended
    function payout(address[] memory attendees) public {
        require(owner == msg.sender, "only owner can payout");
        require(attendees.length <= cap, "too many attendants");
        uint amount = address(this).balance/attendees.length;
        
        for(uint i = 0; i < attendees.length; i++) {
            address payee = attendees[i];
            require(payee != address(0), "invalid address");
            require(participants[payee], "not a participant");
            
            (bool success, ) = payee.call.value(amount)("");
            require(success, "failed to make payment");
        }  
    }
    
    // destroy this contract and send remainder balance to owner
    function destroy() public {
        selfdestruct(owner);
    }
}
