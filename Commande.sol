// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;


contract Commande {
    
    enum etape {commande, expedie, livre}

    struct produit {
        uint _sku;
        Commande.etape _etape;
    }

    mapping(address => produit[]) private _produitByUser;

    function commander(address _client, uint _sku) public {
        produit memory p = produit(_sku, etape.commande);
        _produitByUser[_client].push(p);
    }

    function expedie(address _client, uint _sku) public {
        produit[] storage produits = _produitByUser[_client];
        for(uint i = 0; i < produits.length; i++) {
            if (produits[i]._sku == _sku) {
                produits[i]._etape = etape.expedie;
            }
        }
        _produitByUser[_client] = produits;
    }
    
    function livre(address _client, uint _sku) public {
        produit[] storage produits = _produitByUser[_client];
         for(uint i = 0; i < produits.length; i++) {
            if (produits[i]._sku == _sku) {
                produits[i]._etape = etape.livre;
            }
        }
        _produitByUser[_client] = produits;
    }

    function getProduits() view public returns  (produit[] memory) {
        return _produitByUser[msg.sender];
    }
}
