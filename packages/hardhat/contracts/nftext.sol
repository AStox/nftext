// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721.sol";

library Base64 {
    string internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";
        string memory table = TABLE;
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        string memory result = new string(encodedLen + 32);
        assembly {
            mstore(result, encodedLen)
            let tablePtr := add(table, 1)
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            let resultPtr := add(result, 32)
            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 3)
               let input := mload(dataPtr)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))
               resultPtr := add(resultPtr, 1)
            }
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }
        return result;
    }
}

contract nftext is ERC721 {
    
    address private contractOwner;
    uint256 PRICE = 100;
    uint256 tokenIdCounter;
    mapping(uint256 => string) private _texts;

    constructor() ERC721("nftext", "TEXT"){
        contractOwner = msg.sender;
    }

    function mint(address to, string memory text) public {
        _mint(to, tokenIdCounter);
        // _texts[tokenIdCounter] = text;
        tokenIdCounter++;
    }

    function withdraw() public payable {
        (bool success, ) = payable(contractOwner).call{value: msg.value}("");
        require(success, "Could not transfer money to contractOwner");
    }

    // function walletOfOwner(address _owner) public view returns (uint256[] memory) {
    //     uint256 tokenCount = balanceOf(_owner);
    //     if (tokenCount == 0) {
    //         return new uint256[](0);
    //     }
    //     uint256[] memory tokenIds = new uint256[](tokenCount);
    //     for (uint256 i; i < tokenCount; i++) {
    //         tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    //     }
    //     return tokenIds;
    // }

    function svgGenerator(uint256 tokenId) private view returns (string memory){
        string memory _svgStart = string('<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base {fill: #0D141F; font-size: 14px;} .grey {fill: #3D4D5A;} .white {fill: #A1C2CB;} .muted {fill: #1B3450;} </style><rect width="100%" height="100%" class="base" /><text x="10" y="20" class="base"><tspan x="5" y="10" dy="22" class="white">');
        string memory _svgEnd = string('</tspan></text></svg>');

        return string(abi.encodePacked(_svgStart, _texts[tokenId], _svgEnd));
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string memory svg = svgGenerator(tokenId);
        string memory _json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                    '{"image": "data:image/svg+xml;base64,', Base64.encode(bytes(svg)), ', text: ', _texts[tokenId],'"}'
                    )
                )
            )
        );

        string memory _output = string(
            abi.encodePacked('data:application/json;base64,', _json)
        );
        return _output;
    }
}