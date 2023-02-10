// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MyCollectible is ERC1155, Ownable, ERC1155Supply {
    constructor() ERC1155("") {
        
    }

    address public constant MarketplaceVaultAddress = 0x909957dcc1B114Fe262F4779e6aeD4d034D96B0f;
    
    event ItemCreated(uint _id, address seller);
    event ItemSold(uint _id, address buyer);
    event SellerWithdraw(uint amount, address withdrawer);



    //When seller creates item, mint that nft and let him set a price for the item 
    //When buyer buys item, mint nft and add to the balance of the seller the amount set
    //let seller of items withdraw the balance
    //Let owner of the marketplace withdraw the balance
    //keep track of ids, every seller that creates an item will get a new id(incrementally)

    //more complicated, will see for later
    //When buyer creates item , let him upload an image with the item (get hash from frontend)


    uint public currentId;


    // address of user pointing to ID of item pointing to the sale price of ID of item
    mapping(address => mapping(uint => uint)) userInventory;
    // balance of user, address points to value
    mapping(address => uint) balanceUser;

    function CreateItemToSell(uint sellPrice, uint copiesOfItem) public payable {
        setApprovalForAll(address(this), true);
        currentId++;
        userInventory[msg.sender][currentId] = sellPrice;
        _mint(msg.sender, currentId, copiesOfItem, "");
        emit ItemCreated(currentId, msg.sender);
    }

    function BuyItem(uint _id, address seller, uint _amount) public payable {
       require(msg.value * _amount == userInventory[seller][_id] * _amount, "inssuficient ammount");

       safeTransferFrom(seller, msg.sender, currentId, _amount, "");
       balanceUser[seller] += msg.value;

    }

    function withDrawMarketplace() external onlyOwner {
         uint256 _balance = address(this).balance;
        (bool sent, bytes memory data) = MarketplaceVaultAddress.call{value: _balance}("");
        require(sent, "Failed to send Ether");
    }

    function withDrawSeller() external payable {
       require(balanceUser[msg.sender] <= msg.value, "Not enough funds");
        uint256 _balance = balanceUser[msg.sender];
        uint256 percent = _balance / 100;

        (bool sent, bytes memory data) = msg.sender.call{value: percent * 95}("");
        require(sent, "Failed to send Ether");
    }




        function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}