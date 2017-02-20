
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
        totalSupply = 1000;                        // Update total supply
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
