// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IChronicleOracle {
    error BarNotReached(uint8 numberSigners, uint8 bar);
    error FutureMessage(uint32 givenAge, uint32 currentTimestamp);
    error NotAuthorized(address caller);
    error NotTolled(address caller);
    error SchnorrSignatureInvalid();
    error SignerNotFeed(address signer);
    error SignersNotOrdered();
    error StaleMessage(uint32 givenAge, uint32 currentAge);

    event AuthGranted(address indexed caller, address indexed who);
    event AuthRenounced(address indexed caller, address indexed who);
    event BarUpdated(address indexed caller, uint8 oldBar, uint8 newBar);
    event FeedDropped(address indexed caller, address indexed feed, uint256 indexed index);
    event FeedLifted(address indexed caller, address indexed feed, uint256 indexed index);
    event Poked(address indexed caller, uint128 val, uint32 age);
    event TollGranted(address indexed caller, address indexed who);
    event TollRenounced(address indexed caller, address indexed who);

    function authed(address who) external view returns (bool);

    function authed() external view returns (address[] memory);

    function bar() external view returns (uint8);

    function bud(address who) external view returns (uint256);

    function constructPokeMessage(IScribe.PokeData memory pokeData) external view returns (bytes32);

    function decimals() external view returns (uint8);

    function deny(address who) external;

    function diss(address who) external;

    function drop(uint256 feedIndex) external;

    function drop(uint256[] memory feedIndexes) external;

    function feedRegistrationMessage() external view returns (bytes32);

    function feeds(address who) external view returns (bool, uint256);

    function feeds(uint256 index) external view returns (bool, address);

    function feeds() external view returns (address[] memory, uint256[] memory);

    function isAcceptableSchnorrSignatureNow(bytes32 message, IScribe.SchnorrData memory schnorrData)
        external
        view
        returns (bool);

    function kiss(address who) external;

    function latestAnswer() external view returns (int256);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function lift(LibSecp256k1.Point memory pubKey, IScribe.ECDSAData memory ecdsaData) external returns (uint256);

    function lift(LibSecp256k1.Point[] memory pubKeys, IScribe.ECDSAData[] memory ecdsaDatas)
        external
        returns (uint256[] memory);

    function maxFeeds() external view returns (uint256);

    function peek() external view returns (uint256, bool);

    function peep() external view returns (uint256, bool);

    function poke(IScribe.PokeData memory pokeData, IScribe.SchnorrData memory schnorrData) external;

    function poke_optimized_7136211(IScribe.PokeData memory pokeData, IScribe.SchnorrData memory schnorrData)
        external;

    function read() external view returns (uint256);

    function readWithAge() external view returns (uint256, uint256);

    function rely(address who) external;

    function setBar(uint8 bar_) external;

    function tolled(address who) external view returns (bool);

    function tolled() external view returns (address[] memory);

    function tryRead() external view returns (bool, uint256);

    function tryReadWithAge() external view returns (bool, uint256, uint256);

    function wards(address who) external view returns (uint256);

    function wat() external view returns (bytes32);
}

interface IScribe {
    struct PokeData {
        uint128 val;
        uint32 age;
    }

    struct SchnorrData {
        bytes32 signature;
        address commitment;
        bytes signersBlob;
    }

    struct ECDSAData {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}

interface LibSecp256k1 {
    struct Point {
        uint256 x;
        uint256 y;
    }
}
