pragma solidity ^0.4.2;

// I'd have an apostrophe s...but programming
contract ravens {
    // other owners of the Satori economy...if he deems fit
    address public ravenWallet;
    mapping (address => bool) private owners;

    function ravens(address walletAddress) {
        ravenWallet = walletAddress;     //Forever Satori's Coin -- hardcoded this shit
    }

    modifier onlyOwners {
        if (!owners[msg.sender] && msg.sender != ravenWallet) throw;
        _;
    }

    // The onlySatori modifier ;)
    modifier onlyRaven {
        if (msg.sender != ravenWallet) throw;
        _;
    }

    // Only Satori himself can add or remove owners
    function addOwner(address newOwner) onlyRaven {
        owners[newOwner] = true;
    }

    // What'd you do to get on Satori's bad side?
    function removeOwner(address shitOwner) onlyRaven {
        delete owners[shitOwner];
    }
}

// A Satori...the root of what makes up the great Satori economy
contract RavenBank is ravens {
    // token veresion
    string public version = 'Raven v12.7czx-s1';
    // other properties and shiz
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    // Determine how big the bets will be too...
    uint public tokenPrice;

    struct RavenRisker {
        string      name;
        uint256     ravenBalance;
    }

    mapping (address => uint256) public balanceOf;
    mapping (address => RavenRisker) public riskers;

    /* This generates a public event on the blockchain that will notify clients */
    event RavenRiskerConfirmed(address indexed ravenRisker, string alias);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event TransferRavenOwnership(address indexed oldAddress, address indexed newAddress);

    // The constructor...where it all began
    // Hard coding for assurance that this coin will not be tampered with
    function RavenBank(address walletAddress) ravens (walletAddress) {
        totalSupply = 0;                        // Update total supply
        name = 'Raven';                                    // Satoris
        symbol = 'RAV';                                     // SATs
        decimals = 0;                                       // Round numbers bitch
        riskers[ravenWallet] = RavenRisker('RavenBank', 0); // The Satori Himself
        RavenRiskerConfirmed(ravenWallet, 'RavenBank');
    }

    // Illuminati Only...
    modifier isRavenRisker {
        if (bytes(riskers[msg.sender].name).length == 0) throw;
        _;
    }

    // What can owners do?  Mint SATs of course.
    function mintRavens(address target, uint256 mintedAmount) onlyOwners {
        riskers[target].ravenBalance += mintedAmount;
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, msg.sender, mintedAmount);
        Transfer(msg.sender, target, mintedAmount);
    }

    function changeRavenWallet(address newRaven) onlyRaven {
        riskers[newRaven] = RavenRisker(riskers[ravenWallet].name, riskers[ravenWallet].ravenBalance);
        delete riskers[ravenWallet];
        ravenWallet = newRaven;
    }

    // Only through trade can the Satori market flourish
    function transfer(address _to, uint256 _value) payable isRavenRisker {
        if (_value < 0) throw;                               // Cannot transfer negative balance
        // setup the new following...
        if (bytes(riskers[_to].name).length == 0) {
            riskers[_to] = RavenRisker('New Risker', 0);
        }

        if (riskers[msg.sender].ravenBalance < _value) throw;           // Check if the sender has enough
        if (riskers[_to].ravenBalance + _value < riskers[_to].ravenBalance) throw; // Check for overflows
        riskers[msg.sender].ravenBalance -= _value;                     // Subtract from the sender
        riskers[_to].ravenBalance += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Everyone must know of the Satori trades
    }

    function transferBetweenRiskers(address from, address to, uint256 value) payable onlyOwners {
        if (value < 0) throw;

        if (bytes(riskers[to].name).length == 0) {
            riskers[to] = RavenRisker('New Risker', 0);
        }

        if (riskers[from].ravenBalance < value) throw;
        if (riskers[to].ravenBalance + value < riskers[to].ravenBalance) throw;
        riskers[from].ravenBalance -= value;
        riskers[to].ravenBalance += value;
        Transfer(from, to, value);
    }

    // Identify yourself...
    function setAlias(string alias) {
        if (bytes(riskers[msg.sender].name).length == 0) {
            riskers[msg.sender] = RavenRisker(alias, 0);
        } else {
            riskers[msg.sender].name = alias;
        }
        RavenRiskerConfirmed(msg.sender, alias);
    }

    function transferRavenOwnership(address newAddress) isRavenRisker {
        riskers[newAddress] = RavenRisker(riskers[msg.sender].name, riskers[msg.sender].ravenBalance);
        delete riskers[msg.sender];
        TransferRavenOwnership(msg.sender, newAddress);
    }

    // WTF?!
    function () {
        throw;     // WAI?!?
    }
}

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
    if (bytes(currentBitatoHolder).length != 0) throw;
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

  function joinBitatoRound(string alias, uint endTimeToAdd) payable restrictWhileRunning {
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
    totalTokensCollected += bitatoRoundSize;
    ravenBank.transferBetweenRiskers(msg.sender, this, bitatoRoundSize);

    ParticipantJoined(alias, totalParticipants);

    if (totalParticipants == 10) {
      startBitatoRound();
    }
  }

  function leaveBitatoRound() payable isBitatoParticipant restrictWhileRunning {
    totalParticipants -= 1;
    // transfer balance back out of escrow
    totalTokensCollected -= bitatoRoundSize;
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

  function passBitato() payable isCurrentHolder {
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

// The HotBitatoEscrowManager Contract

contract HotBitatoEscrowManager {

  RavenBank private ravenBank;
  string public version = 'HotBitatoEscrowManager v0.01preAlpha-7';
  address[] hotBitatoRounds;

  event HotBitatoRoundCreated(address indexed hotBitatoRound, uint roundSize);

  function HotBitatoEscrowManager() {
    ravenBank = new RavenBank(this);
  }

  function createBitatoRound(uint roundSize) payable {
    // bail if we are not making a proper round size
    if (roundSize != 10 && roundSize != 100 && roundSize != 1000) throw;

    address newHotBitatoRound = new HotBitatoEscrow(roundSize, ravenBank);
    // add new escrow as owner so it can move value between wallets
    ravenBank.addOwner(newHotBitatoRound);
    hotBitatoRounds.push(newHotBitatoRound);
    HotBitatoRoundCreated(newHotBitatoRound, roundSize);
  }

  function distributeRavens(address walletAddress, uint256 mintedAmount) payable {
    ravenBank.mintRavens(walletAddress, mintedAmount);
  }
}
