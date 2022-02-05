//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Life {
    // https://solidity-by-example.org/hacks/block-timestamp-manipulation/
    // this is a vulnerability 
    uint256 public bornTime;
    uint8 public BOARD_SIZE = 64;
    uint64 public KEY_LENGTH = BOARD_SIZE ** 2;

    constructor() {
        bornTime = block.timestamp; 
    }

    function getElapsedTime() public view returns (uint256) {
        uint256 time = block.timestamp - bornTime; 
        return time;
    }
    
    function zeroTo99() public view returns (uint8) {
        uint256 time = block.timestamp - bornTime; 

        //0 to 100 
        uint8 y = uint8(time % 100);
        return y;
    }

    function addTime(uint256 num) public view returns (uint256) {
        uint256 y = num + getElapsedTime();
        return y;
    }

    function getBlock() public view returns (uint256, uint256) {
        return (block.number, block.timestamp);
    }

    function hash(string memory input) public pure returns (bytes32) {
        return sha256(abi.encodePacked(input));
    }


    // Conway stuff

    function wrapAround(uint64 index) private view returns (uint64) {
        if (index < 0) {
            return index + KEY_LENGTH;
        }

        if (index >= KEY_LENGTH) {
            return index - KEY_LENGTH;
        }

        return index;
    }

    function rowAbove(uint64 index) private view returns(uint64) {
        return wrapAround(index + BOARD_SIZE);
    }

    function rowBelow(uint64 index) private view returns(uint64) {
        return wrapAround(index - BOARD_SIZE);
    }

    function colRight(uint64 index) private view returns(uint64) {
        return wrapAround(index + 1);
    }

    function colLeft(uint64 index) private view returns(uint64) {
        return wrapAround(index - 1);
    }

    function getNeighbors(bool[4096] memory board, uint64 index) private view returns (bool[8] memory) {
        return [
            board[rowAbove(index)], // top
            board[rowAbove(colRight(index))], // top right
            board[colRight(index)], // right
            board[rowBelow(colRight(index))], // bottom right
            board[rowBelow(index)], // bottom
            board[rowBelow(colLeft(index))], // bottom left
            board[colLeft(index)], // left
            board[rowAbove(colLeft(index))] // top left
        ];
    }

    function getLiveNeighborCount(bool[8] memory neighbors) private pure returns (uint8) {
        uint8 liveNeighbors = 0;

        for (uint8 i = 0; i < neighbors.length; i++) {
            if (neighbors[i]) {
                liveNeighbors++;
            }
        }

        return liveNeighbors;
    }

    function calculateLife(bool[4096] memory board, uint64 index) private view returns(bool) {
        bool alive = board[index];
        bool[8] memory neighbors = getNeighbors(board, index);
        uint8 liveNeighborCount = getLiveNeighborCount(neighbors);

        // Any live cell with 2 or 3 live neighbors survives.
        if (alive) {
            if (liveNeighborCount == 2 || liveNeighborCount == 3) {
                return true;
            }
            // Any dead cell with 3 live neighbors becomes a live cell.
        } else if (liveNeighborCount == 3) {
            return true;
        }

        // All other live cells die in the next generation.
        // All other dead cells stay dead.
        return false;
    }

    function calculateNextState(bool[4096] memory board) public view returns(bool[4096] memory) {
        bool[4096] memory newBoard;

        for (uint64 i = 0; i < KEY_LENGTH; i++) {
            newBoard[i] = calculateLife(board, i);
        }

        return newBoard;
    }
}