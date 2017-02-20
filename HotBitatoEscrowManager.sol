contract HotBitatoEscrowManager {

  function HotBitatoEscrowManager() {}

  string public version = 'HotBitatoEscrowManager v0.01preAlpha-7';
  address[] hotBitatoRounds;

  event HotBitatoRoundCreated(address indexed hotBitato1Round, uint roundSize);

  function createBitatoRound(uint256 roundSize) {
    // bail if we are not making a proper round size
    if (roundSize != 1 || roundSize != 10 || roundSize != 100) throw;

    address newHotBitatoRound = new HotBitatoRound(roundSize);
    hotBitatoRounds.push(newHotBitatoRound, roundSize);
    HotBitatoRoundCreated(newHotBitatoRound, roundSize);
  }
}
