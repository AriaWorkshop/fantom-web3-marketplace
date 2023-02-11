// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Marketplace is ERC721, ERC721URIStorage, Ownable {
    constructor() payable ERC721("Marketplace", "MK") {
        
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


    //todo 
    //1. Image upload logic , with ipfs ( when mint upload image , or second step ? I think second step)
    //2. Shipment status returns string
    //3. think about events
    //4. read more state to string to read in the front end
    //5. bought item state for buyer, he will be able to view the items that he bought and shippment status in his page , custom route with address
    //6. shipment address can be viewed only by seller that sold item to the buyer
    uint public currentId;


    // address of user pointing to ID of item pointing to the sale price of ID of item
    mapping(address => mapping(uint => uint)) userInventory;
    // balance of user, address points to value
    mapping(address => uint) balanceUser;
    address[] public sellers;

   enum ShippingStatus {
       OrderReceived,
       ShippingInProgress,
       Shipped
   }

    function CreateItemToSell(uint sellPrice) public payable {
        setApprovalForAll(address(this), true);
        currentId++;
        userInventory[msg.sender][currentId] = sellPrice;
        _mint(msg.sender, currentId);
        sellers.push(msg.sender);
        emit ItemCreated(currentId, msg.sender);
    }

    function BuyItem(uint _id, address seller, uint _amount) public payable {
       require(msg.value * _amount == userInventory[seller][_id] * _amount, "inssuficient ammount");
       ERC721(address(this)).safeTransferFrom(seller, msg.sender, _id);
       balanceUser[seller] += msg.value;
       emit ItemSold(_id, msg.sender);
    }

    function withDrawMarketplace() external onlyOwner {
         uint256 _balance = address(this).balance;
        (bool sent, bytes memory data) = MarketplaceVaultAddress.call{value: _balance}("");
        require(sent, "Failed to send Ether");
    }

    function withDrawSeller(uint _amount) external payable {
     
        uint256 _balance = balanceUser[msg.sender];
        uint256 percent = _balance / 100;

        (bool sent, bytes memory data) = msg.sender.call{value: percent * 95}("");
        require(sent, "Failed to send Ether");
    }


    function getSalePrice(address seller, uint _id) external view returns(uint) {
         uint salePrice = userInventory[seller][_id];
         return salePrice;
    }

    function getUserBalance(address user) external view returns(uint) {
        uint userBalance = balanceUser[user];
        return userBalance;
    }

    function forIdGetSellerAndPrice(uint _id) external view returns (address, uint) {
          uint sellerArrayLen = sellers.length;
          for(uint i = 0; i <= sellerArrayLen; i++) {
            uint price = userInventory[sellers[i]][_id];
               if(price > 0 ) {
                return (sellers[i], price);
               } 
          }
    }

        function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

     function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

}
