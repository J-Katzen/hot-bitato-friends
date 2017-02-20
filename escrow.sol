//
// A contract for running an escrow service for Ethereum token-contracts
//
// Supports the "standardized token API" as described in https://github.com/ethereum/wiki/wiki/Standardized_Contract_APIs
//
// To create an escrow request, follow these steps:
// 1. Call the create() method for setup
// 2. Transfer the tokens to the escrow contract
//
// The recipient can make a simple Ether transfer to get the tokens released to his address.
//
// The buyer pays all the fees (including gas).
//

import { Raven } from "raventoken.sol"

contract HotBitatoEscrow {
  // public
  uint public bitatoRoundSize;
  uint public totalParticipants;
  uint public totalTokensCollected;
  string public bitatoLoser;
  mapping (address => string) public hotBitatoParticipants;

  // private
  uint[] private bitatoOrder;
  mapping (address => uint) private endTimeAdded;
  uint private endTimestamp;
  address private bitatoLoserAddress;

  event ParticipantJoined(string participantAlias, uint totalParticipantCount, uint totalTokensCollectedCount);
  event ParticipantLeft(string participantAlias, uint totalParticipantCount, uint totalTokensCollectedCount);
  event BitatoPass(string oldHolder, string newOlder);
  event BitatoExplode(string bitatoExplodedHolder);
  event BitatoRoundStarted(string firstHolder, uint startTimestamp);

  modifier isBitatoParticipant {
    if (bytes(hotBitatoParticipants[msg.sender]).length == 0) throw;
    _;
  }

  function HotBitatoEscrow(uint escrowSize) {
    endTimestamp = now;
    bitatoRoundSize = escrowSize;
    totalTokensCollected = 0;
    totalParticipants = 0;
    endTimeAdded = 0;
  }

  function joinBitatoRound(string alias, uint endTimeToAdd) {
    if (Raven.balanceOf(msg.sender) < bitatoRoundSize) throw;
    if (endTimeToAdd < 0 || endTimeToAdd > 2) throw;
    if (totalParticipants >= 10) throw;

    hotBitatoParticipants[msg.sender] = alias;
    bitatoOrder
    totalParticipants += 1;
    endTimeAdded[msg.sender] = endTimeToAdd;
    totalTokensCollected += bitatoRoundSize;

    if (totalParticipants == 10) {
      startBitatoRound();
    } else {
      ParticipantJoined(alias, totalParticipants);
    }
  }

  function leaveBitatoRound() isBitatoParticipant {
    totalParticipants -= 1;
    ParticipantLeft(hotBitatoParticipants[msg.sender], totalParticipants);
    delete hotBitatoParticipants[msg.sender];
    delete endTimeAdded[msg.sender];
  }

  function startBitatoRound() {

    BitatoRou
  }


}
