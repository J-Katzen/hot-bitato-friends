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

import { RavenBank } from "raventoken.sol"

// The HotBitatoEscrow Contract

contract HotBitatoEscrow {
  // public
  uint public bitatoRoundSize;
  uint public totalParticipants;
  uint public totalTokensCollected;
  string public bitatoLoser;
  string[] public bitatoParticipants;
  string public currentBitatoHolder;

  // private
  uint private currentBitatoIndex;
  mapping (address => string) private hotBitatoParticipants;
  mapping (string => address) private bitatoParticipantAliasesMap;
  // so if a person leaves, we know how much time to detract
  mapping (address => uint) private endTimeAdded;
  uint private endTimestamp;
  uint private totalEndTimeAdded;
  RavenBank private ravenBank;

  event ParticipantJoined(string participantAlias, uint totalParticipantCount);
  event ParticipantLeft(string participantAlias, uint totalParticipantCount);
  event BitatoPass(string oldHolder, string newOlder);
  event BitatoExplode(string bitatoExplodedHolder);
  event BitatoRoundStarted(string firstHolder, uint startTimestamp);
  event BitatoRoundPaid(string winnerName, uint prizeAmount);
  event BitatoRoundEnded(uint endtime);

  modifier isBitatoParticipant {
    if (bytes(hotBitatoParticipants[msg.sender]).length == 0) throw;
    _;
  }

  modifier restrictWhileRunning {
    if (bytes(currentBitatoHolder).length == 0) throw;
    _;
  }

  modifier isCurrentHolder {
    if (bitatoParticipantAliasesMap[currentBitatoHolder] != msg.sender) throw;
    _;
  }

  function HotBitatoEscrow(uint escrowSize, address ravenBankAddress) {
    endTimestamp = now;
    bitatoRoundSize = escrowSize;
    totalParticipants = 0;
    totalEndTimeAdded = 0;
    currentBitatoIndex = 0;
    ravenBank = RavenBank(ravenBankAddress);
    ravenBank.setAlias('Hot-Bitato-Escrow!~');
  }

  function tokensCollected() returns (uint) {
    return ravenBank.balanceOf(this);
  }

  function joinBitatoRound(string alias, uint endTimeToAdd) restrictWhileRunning {
    if (bytes(alias).length == 0) throw;
    if (ravenBank.balanceOf(msg.sender) < bitatoRoundSize) throw;
    if (endTimeToAdd < 0 || endTimeToAdd > 2) throw;
    if (totalParticipants >= 10) throw;

    // setup participant alias and associate with address
    hotBitatoParticipants[msg.sender] = alias;
    // push into array for public exposure
    bitatoParticipants.push(alias);
    bitatoParticipantAliasesMap[alias] = msg.sender;
    // keep track of participants
    totalParticipants = bitatoParticipants.length;
    endTimeAdded[msg.sender] = endTimeToAdd;
    totalEndTimeAdded += endTimeToAdd;
    // remove balance from user and add to escrow
    ravenBank.transferBetweenRiskers(msg.sender, this, bitatoRoundSize);

    ParticipantJoined(alias, totalParticipants);

    if (totalParticipants == 10) {
      startBitatoRound();
    }
  }

  function leaveBitatoRound() isBitatoParticipant restrictWhileRunning {
    totalParticipants -= 1;
    // transfer balance back out of escrow
    ravenBank.transfer(msg.sender, bitatoRoundSize);
    // initiate left event
    ParticipantLeft(hotBitatoParticipants[msg.sender], totalParticipants);
    string participantAlias = hotBitatoParticipants[msg.sender];
    // delete participant
    delete bitatoParticipantAliasesMap[participantAlias];
    delete hotBitatoParticipants[msg.sender];
    // subtract total end time
    totalEndTimeAdded -= endTimeAdded[msg.sender];
    delete endTimeAdded[msg.sender];
  }


  function startBitatoRound() {
    currentBitatoHolder = bitatoParticipants[currentBitatoIndex];
    calculateRoundTime();
    BitatoRoundStarted(currentBitatoHolder, now);
  }

  function calculateRoundTime() {
    // initialize with at least a 150 second timer (?)
    endTimestamp = (now + (totalEndTimeAdded * 20)) + 150;
  }

  function passBitato() isCurrentHolder {
    if (now > endTimestamp) {
      bitatoLoser = currentBitatoHolder;
      BitatoExplode(currentBitatoHolder);
      BitatoRoundEnded(endTimestamp);
      distributeWinnings();
    } else {
      string oldHolder = bitatoParticipants[currentBitatoIndex];
      if (currentBitatoIndex == 9) {
        currentBitatoIndex = 0;
      } else {
        currentBitatoIndex += 1;
      }

      currentBitatoHolder = bitatoParticipants[currentBitatoIndex];
      BitatoPass(oldHolder, currentBitatoHolder);
    }
  }

  function distributeWinnings() {
    uint winningAmount = bitatoRoundSize + (bitatoRoundSize / 10);
    for (uint i = 0; i < 10; i++) {
      if (i != currentBitatoIndex) {
        ravenBank.transfer(bitatoParticipantAliasesMap[bitatoParticipants[i]], winningAmount);
      }
    }
  }
}
