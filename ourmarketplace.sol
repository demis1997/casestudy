// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;

contract NFTMarketplace {
    struct NFT {
        address owner;
        uint256 price;
        bool forSale;
    }
    
    struct Offer {
        address offerer;
        uint256 amount;
        bool active;
    }
    
    mapping(uint256 => NFT) public nfts;
    mapping(uint256 => Offer) public offers;
    mapping(address => uint256[]) public userNFTs;
    
    uint256 public dailyPrimarySales;
    uint256 public dailySecondarySales;
    uint256 public dailyUsers;
    
    mapping(uint256 => uint256) public projectTotalPrimarySales;
    mapping(uint256 => uint256) public projectTotalSecondarySales;
    mapping(uint256 => uint256) public projectFloor;
    mapping(uint256 => uint256) public projectMedianPrice;
    mapping(uint256 => uint256) public projectDailyPrimarySales;
    mapping(uint256 => uint256) public projectDailySecondarySales;
    
    // Functions for users to put their NFTs for sale
    
    function putNFTForSale(uint256 tokenId, uint256 price) external {
        require(nfts[tokenId].owner == msg.sender, "Only NFT owner can put it for sale");
        nfts[tokenId].forSale = true;
        nfts[tokenId].price = price;
    }
    //receive 
    function acceptSale(uint256 tokenId) external payable {
        require(msg.value >= nfts[tokenId].price, "not enough funds to accept");
        
        address previousOwner = nfts[tokenId].owner;
        
        nfts[tokenId].owner = msg.sender;
        nfts[tokenId].forSale = false;
        nfts[tokenId].price = 0;
        
        payable(previousOwner).transfer(msg.value);
        
        userNFTs[msg.sender].push(tokenId);
    }
    
    // Functions for users to make offers
    
    function makeOffer(uint256 tokenId, uint256 amount) external {
        require(nfts[tokenId].owner != msg.sender, "Cannot make an offer on your own NFT");
        
        offers[tokenId].offerer = msg.sender;
        offers[tokenId].amount = amount;
        offers[tokenId].active = true;
    }
    
    function acceptOffer(uint256 tokenId) external payable {
        require(nfts[tokenId].owner == msg.sender, "Only NFT owner can accept an offer");
        require(offers[tokenId].active, "No active offer for this NFT");
        require(msg.value >= offers[tokenId].amount, "Insufficient funds to accept the offer");
        
        address previousOwner = nfts[tokenId].owner;
        
        nfts[tokenId].owner = msg.sender;
        nfts[tokenId].forSale = false;
        nfts[tokenId].price = 0;
        
        payable(previousOwner).transfer(msg.value);
        
        userNFTs[msg.sender].push(tokenId);
        
        offers[tokenId].active = false;
    }
    
    // check the overal stats
    
    function getOverallStatistics() external view returns (uint256, uint256, uint256) {
        return (dailyPrimarySales, dailySecondarySales, dailyUsers);
    }
    //check floor, primary and secondary sales, average price, 24hr volume etc.
    function getProjectOverallStatistics(uint256 projectId) external view returns (uint256, uint256, uint256, uint256, uint256) {
        return (
            projectTotalPrimarySales[projectId],
            projectTotalSecondarySales[projectId],
            projectFloor[projectId],
            projectMedianPrice[projectId],
            projectDailyPrimarySales[projectId]
        );
    }
}