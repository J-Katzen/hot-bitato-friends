import { RavenBank } from 'raventoken.sol';

// The HotBitatoEscrowManager Contract

contract HotBitatoEscrowManager {

  RavenBank private ravenBank;
  string public version = 'HotBitatoEscrowManager v0.01preAlpha-7';
  address[] hotBitatoRounds;

  event HotBitatoRoundCreated(address indexed hotBitatoRound, uint roundSize);

  function HotBitatoEscrowManager() {
    ravenBank = new RavenBank(this);
  }

  function createBitatoRound(uint roundSize) {
    // bail if we are not making a proper round size
    if (roundSize != 10 && roundSize != 100 && roundSize != 1000) throw;

    address newHotBitatoRound = new HotBitatoEscrow(roundSize, ravenBank);
    // add new escrow as owner so it can move value between wallets
    ravenBank.addOwner(newHotBitatoRound);
    hotBitatoRounds.push(newHotBitatoRound);
    HotBitatoRoundCreated(newHotBitatoRound, roundSize);
  }

  function distributeRavens(address walletAddress, uint256 mintedAmount) {
    ravenBank.mintRavens(walletAddress, mintedAmount);
  }
}
