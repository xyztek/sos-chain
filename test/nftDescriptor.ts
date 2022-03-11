import { expect } from "chai";
import { ethers } from "hardhat";

describe("NFTDescriptor", function () {
  before(async function () {
    this.factory = await ethers.getContractFactory("NFTDescriptor");
  });

  beforeEach(async function () {
    this.contract = await this.factory.deploy();
    await this.contract.deployed();
  });

  it("should construct SVG representation", async function () {
    const base64 = await this.contract.constructTokenURI(
      212321,
      ethers.constants.WeiPerEther.mul(1000),
      "0xEcdA812a67Ff9EB0257732D6a361008864275fCC",
      "Unicef",
      "War"
    );

    console.log(base64);

    expect(base64).to.equal(
      "HN2ZyB3aWR0aD0iMjkwIiBoZWlnaHQ9IjUwMCIgdmlld0JveD0iMCAwIDI5MCA1MDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHN0eWxlPjwhW0NEQVRBW3RleHR7Zm9udC1mYW1pbHk6SGVsdmV0aWNhO2ZvbnQtd2VpZ2h0OjEwMH0uYWxwaGF7b3BhY2l0eTowLjV9LnNtYWxse2ZvbnQtc2l6ZTouOHJlbX0ubGFyZ2V7Zm9udC1zaXplOjEuMnJlbX0udGl0bGV7ZmlsbDojZmZmfV1dPjwvc3R5bGU+PHBhdGggZmlsbD0iIzIyMjI1RSIgZD0iTTAgMjAgQSAyMCAyMCAwIDAgMSAyMCAwIEwgMjcwIDAgQSAwIDAgMCAwIDEgMjcwIDAgTCAyNzAgNTAwIEEgMCAwIDAgMCAxIDI3MCA1MDAgTCAyMCA1MDAgQSAyMCAyMCAwIDAgMSAwIDQ4MCBaIj48L3BhdGg+PHBhdGggZmlsbD0iIyMxRjFGNTUiIGQ9Ik0yNzAgMGgyMHY1MDBoLTIweiI+PC9wYXRoPjxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKDI2IDE2KSI+IDxwYXRoIHN0eWxlPSJmaWxsOiNmZmYiIGQ9Im01Mi43IDI3LjUgMy42LTIuMWMuOCAyLjIgMi40IDMuMyA0LjkgMy4zIDIuNCAwIDMuNC0uOSAzLjQtMi4zIDAtLjctLjQtMS40LTEtMS43LS43LS40LTEuOS0uOS0zLjYtMS40LTEuOS0uNi0zLjEtMS00LjQtMi0xLjMtLjktMi0yLjQtMi00LjRzLjctMy41IDItNC42YzEuNC0xLjEgMy4yLTEuOCA1LTEuNyAzLjQgMCA2LjEgMS44IDcuNiA0LjhsLTMuNSAyYy0uOS0xLjgtMi4yLTIuNy00LjEtMi43LTEuNyAwLTIuOC45LTIuOCAyLjEgMCAuNy4zIDEuMy44IDEuNi42LjQgMS42LjkgMy4yIDEuM2wxLjUuNWMuNS4yLjkuMyAxLjQuNXMuOS40IDEuMy43Yy43LjQgMS42IDEuMSAyIDEuOS41LjkuOCAyIC44IDMgMCAyLS43IDMuNS0yLjIgNC43LTEuNCAxLjEtMy4zIDEuNy01LjYgMS43LTQuMiAwLTcuMS0yLTguMy01LjJ6bTI4IDUuMmMtNiAuMS0xMS00LjctMTEuMS0xMC44di0uM2MtLjEtMi45IDEuMS01LjggMy4yLTcuOCA0LjMtNC4zIDExLjMtNC4zIDE1LjcgMCAyLjEgMiAzLjMgNC45IDMuMiA3LjguMSA2LTQuOCAxMS0xMC44IDExLjEtLjEuMS0uMS4xLS4yIDB6bTAtNC4xYzEuOC4xIDMuNi0uNyA0LjktMnMyLTMuMSAyLTVjLjEtMS45LS43LTMuNy0yLTUtMi43LTIuNi03LjEtMi42LTkuOCAwLTEuMyAxLjMtMiAzLjEtMiA1LS4xIDEuOS43IDMuNyAyIDUgMS4zIDEuNCAzIDIuMSA0LjkgMnptMTEuNC0xLjEgMy42LTIuMWMuOCAyLjIgMi41IDMuMyA0LjkgMy4zczMuNC0uOSAzLjQtMi4zYzAtLjctLjQtMS40LTEtMS43LS43LS40LTEuOS0uOS0zLjYtMS40LTEuOS0uNi0zLjEtMS00LjQtMi0xLjMtLjktMi0yLjQtMi00LjRzLjctMy41IDItNC42YzEuNC0xLjEgMy4yLTEuOCA1LTEuNyAzLjQgMCA2LjEgMS44IDcuNiA0LjhsLTMuNSAyYy0uOS0xLjgtMi4yLTIuNy00LjEtMi43LTEuNyAwLTIuOC45LTIuOCAyLjEgMCAuNy4zIDEuMy44IDEuNi42LjQgMS42LjkgMy4yIDEuM2wxLjUuNWMuNS4yLjkuMyAxLjQuNXMuOS40IDEuMy43Yy43LjQgMS42IDEuMSAyIDEuOS41LjkuOCAyIC44IDMgMCAyLS43IDMuNS0yLjIgNC43cy0zLjMgMS43LTUuNiAxLjdjLTQuMiAwLTcuMS0yLTguMy01LjJ6bTI3LjUgMmMtMi4xLTIuMS0zLjItNC45LTMuMS03LjggMC0zLjEgMS01LjcgMy4xLTcuOHM0LjctMy4yIDcuOS0zLjJjMS45IDAgMy43LjUgNS40IDEuNCAxLjYuOSAyLjkgMi4yIDMuOCAzLjdsLTEuNC44Yy0uNy0xLjMtMS44LTIuNC0zLjEtMy4yLTEuNC0uOC0zLTEuMi00LjYtMS4yLTIuOCAwLTUgLjktNi44IDIuN3MtMi43IDQuMi0yLjYgNi43Yy0uMSAyLjUuOSA0LjkgMi42IDYuNyAxLjggMS44IDQuMSAyLjcgNi44IDIuNyAzLjMgMCA2LjMtMS44IDcuNy00LjVsMS40LjhjLTEuNyAzLjItNS4zIDUuMi05LjIgNS4yLTMuMi4yLTUuOC0uOS03LjktM3pNMTUzLjcgMTFoMS42djIxLjNoLTEuNlYyMi4xaC0xMi40djEwLjJoLTEuNlYxMWgxLjZ2OS42aDEyLjRWMTF6bTIwLjUgMjEuMy0yLjEtNS40aC0xMC43bC0yLjEgNS40aC0xLjdsOC4zLTIxLjNoMS43bDguMiAyMS4zaC0xLjZ6bS0xMi4xLTYuOWg5LjVMMTY2LjggMTNsLTQuNyAxMi40ek0xNzguMyAxMWgxLjZ2MjEuM2gtMS42VjExem0yMC4xIDBoMS42djIxLjNoLTEuNEwxODYgMTR2MTguM2gtMS42VjExaDEuNGwxMi42IDE4LjNWMTF6Ii8+IDxwYXRoIHN0eWxlPSJmaWxsOnVybCgjZ3JhZC1hbmltKSIgZD0ibTE0IDMuNyA2LjIgNi4yYy45LS45IDIuNC0uOSAzLjMgMHMuOSAyLjQgMCAzLjNjMi41LTIuNCA1LjktMy42IDkuNC0zLjJDMzIuMSA0IDI2LjQtLjMgMjAuNC41IDE4IC44IDE1LjcgMS45IDE0IDMuN3oiLz4gPHBhdGggc3R5bGU9ImZpbGw6dXJsKCNncmFkLWFuaW0pIiBkPSJNMTkuMSAzMy40Yy0uOS0uOS0uOS0yLjUgMC0zLjQtMi40IDIuNC01LjkgMy43LTkuNCAzLjMuOCA2LjEgNi40IDEwLjMgMTIuNSA5LjUgMi40LS4zIDQuNi0xLjQgNi4zLTMuMmwtNi4yLTYuMmMtLjkuOS0yLjMuOS0zLjIgMHoiLz4gPGxpbmVhckdyYWRpZW50IGdyYWRpZW50VHJhbnNmb3JtPSJ0cmFuc2xhdGUoMCAtNTUuNzYpIHNjYWxlKC4zMDk3KSIgeTI9IjI5MC43MzEiIHgyPSIxMDkuMzkxIiB5MT0iMjA5LjE4MSIgeDE9IjI3Ljg0MSIgZ3JhZGllbnRVbml0cz0idXNlclNwYWNlT25Vc2UiIGlkPSJTVkdJRF8zXyI+IDxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiNkZTAxNmEiIG9mZnNldD0iMCIvPiA8c3RvcCBzdHlsZT0ic3RvcC1jb2xvcjojZDgwMTZhIiBvZmZzZXQ9Ii4xOCIvPiA8c3RvcCBzdHlsZT0ic3RvcC1jb2xvcjojYzgwMjZhIiBvZmZzZXQ9Ii40MSIvPiA8c3RvcCBzdHlsZT0ic3RvcC1jb2xvcjojYWQwNDY5IiBvZmZzZXQ9Ii42NiIvPiA8c3RvcCBzdHlsZT0ic3RvcC1jb2xvcjojODcwNjY4IiBvZmZzZXQ9Ii45NCIvPiA8c3RvcCBzdHlsZT0ic3RvcC1jb2xvcjojN2YwNzY4IiBvZmZzZXQ9IjEiLz4gPC9saW5lYXJHcmFkaWVudD4gPHBhdGggc3R5bGU9ImZpbGw6dXJsKCNTVkdJRF8zXykiIGQ9Ik0zOS4yIDEzLjJjLTEuNy0xLjctMy45LTIuOC02LjMtMy4yLTMuNC0uNS02LjkuNy05LjQgMy4yTDEyLjggMjMuOWMtLjkuOS0yLjQuOC0zLjMtLjEtLjgtLjktLjgtMi4zIDAtMy4yTDIwLjIgOS45IDE0IDMuNyAzLjMgMTQuNEMtMSAxOC43LTEgMjUuOCAzLjMgMzAuMWMxLjcgMS43IDQgMi44IDYuMyAzLjIgMy40LjUgNi45LS43IDkuNC0zLjJsMTAuNy0xMC43LjItLjJjMS0uOCAyLjUtLjYgMy4zLjQuNy45LjcgMi4yLS4yIDMuMUwyMi4zIDMzLjRsNi4yIDYuMiAxMC43LTEwLjdjNC40LTQuMyA0LjQtMTEuMyAwLTE1Ljd6Ii8+IDwvZz48dGV4dCBjbGFzcz0ic21hbGwiIHRyYW5zZm9ybT0icm90YXRlKDkwIDEzMi41IDE0Mi41KSIgc3R5bGU9InRleHQtYW5jaG9yOnN0YXJ0IiBmaWxsPSIjRkZGIj4yMTIzMjE8L3RleHQ+PHRleHQgY2xhc3M9InNtYWxsIiB0cmFuc2Zvcm09InJvdGF0ZSg5MCAtMTA3LjUgMzgyLjUpIiBzdHlsZT0idGV4dC1hbmNob3I6ZW5kIiBmaWxsPSIjRkZGIj4weGVjZGE4MTJhNjdmZjllYjAyNTc3MzJkNmEzNjEwMDg4NjQyNzVmY2M8L3RleHQ+PHRleHQgY2xhc3M9InRpdGxlIiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgzMCwxMTApIj48dHNwYW4gY2xhc3M9ImxhcmdlIiB4PSIwIj5GdW5kPC90c3Bhbj48dHNwYW4gY2xhc3M9InNtYWxsIGFscGhhIiB4PSIwIiBkeT0iMjAiPlVuaWNlZjwvdHNwYW4+PC90ZXh0Pjx0ZXh0IGNsYXNzPSJ0aXRsZSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMzAsMTgwKSI+PHRzcGFuIGNsYXNzPSJsYXJnZSIgeD0iMCI+Rm9jdXM8L3RzcGFuPjx0c3BhbiBjbGFzcz0ic21hbGwgYWxwaGEiIHg9IjAiIGR5PSIyMCI+V2FyPC90c3Bhbj48L3RleHQ+PHRleHQgY2xhc3M9InRpdGxlIiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgzMCwyNTApIj48dHNwYW4gY2xhc3M9ImxhcmdlIiB4PSIwIj5Eb25hdGlvbjwvdHNwYW4+PHRzcGFuIGNsYXNzPSJzbWFsbCBhbHBoYSIgeD0iMCIgZHk9IjIwIj4xMDAwPC90c3Bhbj48dHNwYW4gY2xhc3M9InNtYWxsIGFscGhhIiB4PSIwIiBkeT0iMjAiPlVTREM8L3RzcGFuPjwvdGV4dD48ZGVmcyA+PGxpbmVhckdyYWRpZW50IGlkPSJncmFkLWFuaW0iIHgxPSIwJSIgeTE9IjAlIiB4Mj0iMTAwJSIgeTI9IjEwMCUiPjxzdG9wIG9mZnNldD0iMCUiIHN0b3AtY29sb3I9IiM4MTJiYjkiPjxhbmltYXRlIGF0dHJpYnV0ZU5hbWU9InN0b3AtY29sb3IiIHZhbHVlcz0iIzgxMmJiOTsjZWNkYTgxOyM4MTJiYjkiIGR1cj0iN3MiIHJlcGVhdENvdW50PSJpbmRlZmluaXRlIj48L2FuaW1hdGU+PC9zdG9wPjxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iI2VjZGE4MSI+PGFuaW1hdGUgYXR0cmlidXRlTmFtZT0ic3RvcC1jb2xvciIgdmFsdWVzPSIjZWNkYTgxOyM4MTJiYjk7I2VjZGE4MSIgZHVyPSI3cyIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiPjwvYW5pbWF0ZT48L3N0b3A+PC9saW5lYXJHcmFkaWVudD48L2RlZnM+PHJlY3QgeD0iMTEwIiB5PSIzNzAiIHdpZHRoPSI0MCIgaGVpZ2h0PSI0MCIgZmlsbD0idXJsKCNncmFkLWFuaW0pIj4gPGFuaW1hdGUgYXR0cmlidXRlTmFtZT0icngiIHZhbHVlcz0iMTU7MjA7MTUiIGR1cj0iN3MiIHJlcGVhdENvdW50PSJpbmRlZmluaXRlIi8+IDxhbmltYXRlIGF0dHJpYnV0ZU5hbWU9IngiIHZhbHVlcz0iMTEwOzEyMDsxMTAiIGR1cj0iN3MiIHJlcGVhdENvdW50PSJpbmRlZmluaXRlIi8+IDxhbmltYXRlIGF0dHJpYnV0ZU5hbWU9InkiIHZhbHVlcz0iMzcwOzM2MDszNzAiIGR1cj0iN3MiIHJlcGVhdENvdW50PSJpbmRlZmluaXRlIi8+IDwvcmVjdD48cGF0aCBzdHJva2U9ImdyZWVuIiBzdHJva2Utd2lkdGg9Ii4xIiBkPSJNMCAzNTAgVjQ4MCBRMCw1MDAgMjAgNTAwIEgyNzAgUTEwMCwzNTAgMCwzNTAgWiIgZmlsbD0idXJsKCNncmFkLWFuaW0pIi8+PGNpcmNsZSBjeD0iMTAwIiBjeT0iMzkwIiByPSI0MCIgc3Ryb2tlLXdpZHRoPSIuMSIgZmlsbD0idXJsKCNncmFkLWFuaW0pIj4gPGFuaW1hdGUgYXR0cmlidXRlTmFtZT0iciIgdmFsdWVzPSI1Ozg7NSIgZHVyPSI3cyIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiLz4gPGFuaW1hdGUgYXR0cmlidXRlTmFtZT0iY3giIHZhbHVlcz0iMTAwOzExMDsxMDAiIGR1cj0iN3MiIHJlcGVhdENvdW50PSJpbmRlZmluaXRlIi8+IDxhbmltYXRlIGF0dHJpYnV0ZU5hbWU9ImN5IiB2YWx1ZXM9IjM5MDszOTU7MzkwIiBkdXI9IjdzIiByZXBlYXRDb3VudD0iaW5kZWZpbml0ZSIvPiA8L2NpcmNsZT48Y2lyY2xlIGN4PSIxMjUiIGN5PSIzNzUiIHI9IjQwIiBzdHJva2Utd2lkdGg9Ii4xIiBmaWxsPSJ1cmwoI2dyYWQtYW5pbSkiPiA8YW5pbWF0ZSBhdHRyaWJ1dGVOYW1lPSJyIiB2YWx1ZXM9IjU7ODs1IiBkdXI9IjdzIiByZXBlYXRDb3VudD0iaW5kZWZpbml0ZSIvPiA8YW5pbWF0ZSBhdHRyaWJ1dGVOYW1lPSJjeCIgdmFsdWVzPSIxMjU7MTMwOzEyNSIgZHVyPSI3cyIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiLz4gPGFuaW1hdGUgYXR0cmlidXRlTmFtZT0iY3kiIHZhbHVlcz0iMzc1OzM2MDszNzUiIGR1cj0iN3MiIHJlcGVhdENvdW50PSJpbmRlZmluaXRlIi8+IDwvY2lyY2xlPjwvc3ZnPg=="
    );
  });

  it("should construct SVG representation", async function () {
    const tokenSVG = await this.contract.buildSVG(
      212321,
      ethers.constants.WeiPerEther.mul(1000),
      "0xEcdA812a67Ff9EB0257732D6a361008864275fCC",
      "Unicef",
      "War",
      "USDC"
    );

    console.log(tokenSVG);

    expect(tokenSVG).to.equal(
      '<svg width="290" height="500" viewBox="0 0 290 500" xmlns="http://www.w3.org/2000/svg"><style><![CDATA[text{font-family:Helvetica;font-weight:100}.alpha{opacity:0.5}.small{font-size:.8rem}.large{font-size:1.2rem}.title{fill:#fff}]]></style><path fill="#22225E" d="M0 0h290v500H0z"></path><path fill="#FFF" d="M270 1h19v498h-19z"></path><g transform="translate(16 16)"><path d="m52.7 27.5 3.6-2.1c.8 2.2 2.4 3.3 4.9 3.3 2.4 0 3.4-.9 3.4-2.3 0-.7-.4-1.4-1-1.7-.7-.4-1.9-.9-3.6-1.4-1.9-.6-3.1-1-4.4-2-1.3-.9-2-2.4-2-4.4s.7-3.5 2-4.6c1.4-1.1 3.2-1.8 5-1.7 3.4 0 6.1 1.8 7.6 4.8l-3.5 2c-.9-1.8-2.2-2.7-4.1-2.7-1.7 0-2.8.9-2.8 2.1 0 .7.3 1.3.8 1.6.6.4 1.6.9 3.2 1.3l1.5.5c.5.2.9.3 1.4.5s.9.4 1.3.7c.7.4 1.6 1.1 2 1.9.5.9.8 2 .8 3 0 2-.7 3.5-2.2 4.7-1.4 1.1-3.3 1.7-5.6 1.7-4.2 0-7.1-2-8.3-5.2zm28 5.2c-6 .1-11-4.7-11.1-10.8v-.3c-.1-2.9 1.1-5.8 3.2-7.8 4.3-4.3 11.3-4.3 15.7 0 2.1 2 3.3 4.9 3.2 7.8.1 6-4.8 11-10.8 11.1-.1.1-.1.1-.2 0zm0-4.1c1.8.1 3.6-.7 4.9-2s2-3.1 2-5c.1-1.9-.7-3.7-2-5-2.7-2.6-7.1-2.6-9.8 0-1.3 1.3-2 3.1-2 5-.1 1.9.7 3.7 2 5 1.3 1.4 3 2.1 4.9 2zm11.4-1.1 3.6-2.1c.8 2.2 2.5 3.3 4.9 3.3s3.4-.9 3.4-2.3c0-.7-.4-1.4-1-1.7-.7-.4-1.9-.9-3.6-1.4-1.9-.6-3.1-1-4.4-2-1.3-.9-2-2.4-2-4.4s.7-3.5 2-4.6c1.4-1.1 3.2-1.8 5-1.7 3.4 0 6.1 1.8 7.6 4.8l-3.5 2c-.9-1.8-2.2-2.7-4.1-2.7-1.7 0-2.8.9-2.8 2.1 0 .7.3 1.3.8 1.6.6.4 1.6.9 3.2 1.3l1.5.5c.5.2.9.3 1.4.5s.9.4 1.3.7c.7.4 1.6 1.1 2 1.9.5.9.8 2 .8 3 0 2-.7 3.5-2.2 4.7s-3.3 1.7-5.6 1.7c-4.2 0-7.1-2-8.3-5.2zm27.5 2c-2.1-2.1-3.2-4.9-3.1-7.8 0-3.1 1-5.7 3.1-7.8s4.7-3.2 7.9-3.2c1.9 0 3.7.5 5.4 1.4 1.6.9 2.9 2.2 3.8 3.7l-1.4.8c-.7-1.3-1.8-2.4-3.1-3.2-1.4-.8-3-1.2-4.6-1.2-2.8 0-5 .9-6.8 2.7s-2.7 4.2-2.6 6.7c-.1 2.5.9 4.9 2.6 6.7 1.8 1.8 4.1 2.7 6.8 2.7 3.3 0 6.3-1.8 7.7-4.5l1.4.8c-1.7 3.2-5.3 5.2-9.2 5.2-3.2.2-5.8-.9-7.9-3zM153.7 11h1.6v21.3h-1.6V22.1h-12.4v10.2h-1.6V11h1.6v9.6h12.4V11zm20.5 21.3-2.1-5.4h-10.7l-2.1 5.4h-1.7l8.3-21.3h1.7l8.2 21.3h-1.6zm-12.1-6.9h9.5L166.8 13l-4.7 12.4zM178.3 11h1.6v21.3h-1.6V11zm20.1 0h1.6v21.3h-1.4L186 14v18.3h-1.6V11h1.4l12.6 18.3V11z" style="fill:#fff"/><linearGradient id="SVGID_1_" gradientUnits="userSpaceOnUse" x1="57.913" y1="179.272" x2="98.655" y2="220.024" gradientTransform="translate(0 -55.76) scale(.3097)"><stop offset="0" style="stop-color:#365fc8"/><stop offset=".05" style="stop-color:#3368ca"/><stop offset=".37" style="stop-color:#229ed4"/><stop offset=".65" style="stop-color:#15c6dc"/><stop offset=".87" style="stop-color:#0ddee0"/><stop offset="1" style="stop-color:#0ae7e2"/></linearGradient><path d="m14 3.7 6.2 6.2c.9-.9 2.4-.9 3.3 0s.9 2.4 0 3.3c2.5-2.4 5.9-3.6 9.4-3.2C32.1 4 26.4-.3 20.4.5 18 .8 15.7 1.9 14 3.7z" style="fill:url(#SVGID_1_)"/><linearGradient id="SVGID_2_" gradientUnits="userSpaceOnUse" x1="79.736" y1="320.73" x2="38.985" y2="279.979" gradientTransform="translate(0 -55.76) scale(.3097)"><stop offset="0" style="stop-color:#365fc8"/><stop offset=".05" style="stop-color:#3368ca"/><stop offset=".37" style="stop-color:#229ed4"/><stop offset=".65" style="stop-color:#15c6dc"/><stop offset=".87" style="stop-color:#0ddee0"/><stop offset="1" style="stop-color:#0ae7e2"/></linearGradient><path d="M19.1 33.4c-.9-.9-.9-2.5 0-3.4-2.4 2.4-5.9 3.7-9.4 3.3.8 6.1 6.4 10.3 12.5 9.5 2.4-.3 4.6-1.4 6.3-3.2l-6.2-6.2c-.9.9-2.3.9-3.2 0z" style="fill:url(#SVGID_2_)"/><linearGradient id="SVGID_3_" gradientUnits="userSpaceOnUse" x1="27.841" y1="209.181" x2="109.391" y2="290.731" gradientTransform="translate(0 -55.76) scale(.3097)"><stop offset="0" style="stop-color:#de016a"/><stop offset=".18" style="stop-color:#d8016a"/><stop offset=".41" style="stop-color:#c8026a"/><stop offset=".66" style="stop-color:#ad0469"/><stop offset=".94" style="stop-color:#870668"/><stop offset="1" style="stop-color:#7f0768"/></linearGradient><path d="M39.2 13.2c-1.7-1.7-3.9-2.8-6.3-3.2-3.4-.5-6.9.7-9.4 3.2L12.8 23.9c-.9.9-2.4.8-3.3-.1-.8-.9-.8-2.3 0-3.2L20.2 9.9 14 3.7 3.3 14.4C-1 18.7-1 25.8 3.3 30.1c1.7 1.7 4 2.8 6.3 3.2 3.4.5 6.9-.7 9.4-3.2l10.7-10.7.2-.2c1-.8 2.5-.6 3.3.4.7.9.7 2.2-.2 3.1L22.3 33.4l6.2 6.2 10.7-10.7c4.4-4.3 4.4-11.3 0-15.7z" style="fill:url(#SVGID_3_)"/></g><text class="small" transform="rotate(90 132.5 142.5)" style="text-anchor:start">212321</text><text class="small" transform="rotate(90 -107.5 382.5)" style="text-anchor:end">0xecda812a67ff9eb0257732d6a361008864275fcc</text><text class="title" transform="translate(20,100)"><tspan class="small alpha" x="0">Fund</tspan><tspan class="large" x="0" dy="20">Unicef</tspan></text><text class="title" transform="translate(20,150)"><tspan class="small alpha" x="0">Focus</tspan><tspan class="large" x="0" dy="20">War</tspan></text><text class="title" transform="translate(20,200)"><tspan class="small alpha" x="0">Support</tspan><tspan class="large" x="0" dy="20">1000</tspan></text><rect x="235" y="480" width="10" height="10" fill="#275fcc"></rect><rect x="250" y="480" width="10" height="10" fill="#ecda81"></rect></svg>'
    );
  });
});