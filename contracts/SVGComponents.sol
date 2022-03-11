// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";



contract SVGComponents {
    using Strings for uint256;

    function colorToGridAnim(string memory colorA, string memory colorB)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodePacked(
                tag(
                    abi.encodePacked("defs"),
                    abi.encodePacked(""),
                    abi.encodePacked(
                        tag(
                            abi.encodePacked("linearGradient"),
                            abi.encodePacked(
                                keyValue("id", "grad-anim"),
                                " ",
                                keyValue("x1", "0%"),
                                " ",
                                keyValue("y1", "0%"),
                                " ",
                                keyValue("x2", "100%"),
                                " ",
                                keyValue("y2", "100%")
                            ),
                            abi.encodePacked(
                                colorToGridAnimHelper(colorA, colorB, "0%"),
                                colorToGridAnimHelper(colorB, colorA, "100%")
                            )
                        )
                    )
                )
            );
    }

    function colorToGridAnimHelper(
        string memory colorA,
        string memory colorB,
        string memory offset
    ) internal pure returns (bytes memory) {
        return
            tag(
                abi.encodePacked("stop"),
                abi.encodePacked(
                    keyValue("offset", abi.encodePacked(offset)),
                    " ",
                    keyValue("stop-color", abi.encodePacked("#", colorA))
                ),
                abi.encodePacked(
                    tag(
                        abi.encodePacked("animate"),
                        abi.encodePacked(
                            keyValue("attributeName", "stop-color"),
                            " ",
                            keyValue(
                                "values",
                                
                                    abi.encodePacked("#",colorA,";#",colorB,";#",colorA)
                                    /*abi.encodePacked("#", colorA),
                                    ";",
                                    abi.encodePacked("#", colorB),
                                    ";",
                                    abi.encodePacked("#", colorA)*/
                                
                            ),
                            " ",
                            keyValue("dur", "7s"),
                            " ",
                            keyValue("repeatCount", "indefinite")
                        ),
                        abi.encodePacked("")
                    )
                )
            );
    }

    function background() internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                tag(
                    abi.encodePacked("path"),
                    abi.encodePacked(
                        'fill="#22225E" d="M0 20 A 20 20 0 0 1 20 0 L 270 0 A 0 0 0 0 1 270 0 L 270 500 A 0 0 0 0 1 270 500 L 20 500 A 20 20 0 0 1 0 480 Z"'
                    ),
                    abi.encodePacked("")
                ),
                tag(
                    abi.encodePacked("path"),
                    abi.encodePacked('fill="#1F1F55" d="M270 0h20v500h-20z"'),
                    abi.encodePacked("")
                )
            );
    }

    function sideText(
        bytes memory _text,
        bytes memory _transform,
        bytes memory _style,
        bytes memory _textSize,
        bytes memory _fillColor
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                tag(
                    abi.encodePacked("text"),
                    abi.encodePacked(
                        keyValue(
                            abi.encodePacked("class"),
                            abi.encodePacked(_textSize)
                        ),
                        " ",
                        keyValue(abi.encodePacked("transform"), _transform),
                        " ",
                        keyValue(abi.encodePacked("style"), _style),
                        " ",
                        keyValue(abi.encodePacked("fill"), _fillColor)
                    ),
                    _text
                )
            );
    }

    function titleStack(
        uint256 _x,
        uint256 _y,
        bytes memory _sub,
        bytes memory _title
    ) internal pure returns (bytes memory) {
        return
            tag(
                abi.encodePacked("text"),
                abi.encodePacked(
                    'class="title" transform=',
                    '"translate(',
                    _x.toString(),
                    ",",
                    _y.toString(),
                    ')"'
                ),
                abi.encodePacked(
                    tag(
                        abi.encodePacked("tspan"),
                        abi.encodePacked('class="large" x="0"'),
                        _sub
                    ),
                    tag(
                        abi.encodePacked("tspan"),
                        abi.encodePacked('class="small alpha" x="0" dy="20"'),
                        _title
                    )
                )
            );
    }

    function titleStackTokenSymbol(
        uint256 _x,
        uint256 _y,
        bytes memory _sub,
        bytes memory _title,
        bytes memory _tokenSymbol
    ) internal pure returns (bytes memory) {
        return
            tag(
                abi.encodePacked("text"),
                abi.encodePacked(
                    'class="title" transform=',
                    '"translate(',
                    _x.toString(),
                    ",",
                    _y.toString(),
                    ')"'
                ),
                abi.encodePacked(
                    tag(
                        abi.encodePacked("tspan"),
                        abi.encodePacked('class="large" x="0"'),
                        _sub
                    ),
                    tag(
                        abi.encodePacked("tspan"),
                        abi.encodePacked('class="small alpha" x="0" dy="20"'),
                        abi.encodePacked(_title, " ", _tokenSymbol)
                    )
                    /*tag(
                        abi.encodePacked("tspan"),
                        abi.encodePacked('class="small alpha" x="0" dy="20"'),
                        _tokenSymbol
                    )*/
                )
            );
    }

    function tag(
        bytes memory _name,
        bytes memory _attributes,
        bytes memory _contents
    ) public pure returns (bytes memory) {
        return
            abi.encodePacked(
                "<",
                _name,
                " ",
                _attributes,
                ">",
                _contents,
                "</",
                _name,
                ">"
            );
    }

    function toRGBA(
        string memory r,
        string memory b,
        string memory g,
        string memory a
    ) public pure returns (bytes memory) {
        return abi.encodePacked("rgba(", r, ",", b, ",", g, ",", a, ")");
    }

    function keyValue(bytes memory _key, bytes memory _value)
        public
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(_key, "=", '"', _value, '"');
    }

    function toPixelValue(uint256 value) public pure returns (bytes memory) {
        return abi.encodePacked(value.toString(), "px");
    }

    function rPad(bytes memory str) public pure returns (bytes memory) {
        return abi.encodePacked(str, " ");
    }
}
