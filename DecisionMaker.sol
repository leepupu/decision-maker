pragma solidity ^0.5.0;

contract DecisionMaker {
    uint256 public value;
    uint32 public decisionsCount;
    uint32 public finalDecision;
    uint256 public bankTotal;
    address payable public owner;
    mapping (uint32 => uint256) bank;
    bool public active;

    uint256 public rangeRand;


    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function add32(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub32(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b <= a);
        uint32 c = a - b;

        return c;
    }

    function update() public {
        value = rand;
    }

    function get() public view returns (uint256) {
        return value;
    }

    function setDecisionsCount(uint32 c, uint256 init) public restricted {
        if (active) {
            assert(c > 0);
            decisionsCount = c;
            for(uint32 i=0;i<c;i++) {
                bank[i] = init;
            }
        }
    }

    function addChip(uint32 decision) public payable {
        if (active) {
            uint32 t = sub32(decision, 1);
            assert(t < decisionsCount);
            bank[t] = add(msg.value, bank[t]);
            bankTotal = add(msg.value, bankTotal);
        }
    }

    function getFinalDecision() public view returns (uint32) {
        return finalDecision;
    }

    function makeDecision() public payable  restricted returns (uint32) {
        if(active) {
            active = false;
            uint256 result = rand % bankTotal;
            // DEBUG
            rangeRand = result;
            uint256 counter;
            for(uint32 i=0;i<decisionsCount;i++) {
                counter = add(counter, bank[i]);
                if (result < counter) {
                    owner.transfer(bankTotal);
                    // msg.sender.transfer(100);

                    finalDecision = add32(i, 1);
                    return add32(i, 1); // For human readable
                }
            }
            return 0; // Mark failed
        }
    }

    constructor() public {
        owner = msg.sender;
        active = true;
    }
}
