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
        uint8 y = mod(time, 100);
        return y;
    }

    function addTime(uint256 num) public view returns (uint256) {
        uint256 y = num + getElapsedTime();
        return y;
    }

    function getBlock() public view returns (uint256, uint256) {
        return (block.number, block.timestamp);
    }

    function hash(string memory input) public view returns (bytes) {
        return sha256(abi.encodePacked(input));
    }

    function getLiveNeighborCount(bool[8] neighbors) public view returns (uint8) {
        uint8 liveNeighbors = 0;

        for (uint256 i = 0; i < neighbors.length; i++) {
            if (neighbors[i]) {
                liveNeighbors++;
            }
        }

        return liveNeighbors;
    }
 
    function calculateLife(bool[8] neighbors, bool alive) public view returns(bool) {
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

    function wrapAround(uint64 index) public view returns (uint64) {
        if (index < 0) {
            return index + KEY_LENGTH;
        }

        if (index >= KEY_LENGTH) {
            return index - KEY_LENGTH;
        }

        return index;
    }


    function rowAbove(uint64 index) public view returns(bool) {
        return wrapAround(index + BOARD_SIZE);
    }

    function rowBelow(uint64 index) public view returns(bool) {
        return wrapAround(index - BOARD_SIZE);
    }

    function colRight(uint64 index) public view returns(bool) {
        return wrapAround(index + 1);
    }

    function colLeft(uint64 index) public view returns(bool) {
        return wrapAround(index - 1);
    }


    function getNeighbors(bool[KEY_LENGTH] board, uint256 index) public view returns (bool[8]) {
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


    function calculateNextState(bool[KEY_LENGTH] board) public view returns(bool[KEY_LENGTH]) {
        bool[KEY_LENGTH] newBoard;

        for (uint256 i = 0; i < KEY_LENGTH; i++) {
            bool[8] neighbors = getNeighbors(board, i);
            newBoard[i] = calculateLife(neighbors, board[i]);
        }

        return newBoard;
    }
}