//
//  ProductVariantEntityUpdateServiceSpec.swift
//  ShopAppTests
//
//  Created by Radyslav Krechet on 3/29/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreData

import CoreStore
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ProductVariantEntityUpdateServiceSpec: QuickSpec {
    override func spec() {
        beforeEach {
            DataBaseConfig.setup(inMemoryStore: true)
        }
        
        describe("when update service used") {
            it("needs to update entity with item") {
                let variantOption = VariantOption()
                variantOption.name = "name"
                
                let image = Image()
                image.id = "id"
                image.src = "src"
                
                let item = ProductVariant()
                item.id = "id"
                item.price = 5.5
                item.title = "title"
                item.available = true
                item.productId = "productId"
                item.selectedOptions = [variantOption]
                item.image = image
                
                waitUntil(timeout: 10) { done in
                    CoreStore.perform(asynchronous: { transaction in
                        let entity = transaction.create(Into<ProductVariantEntity>())
                        
                        ProductVariantEntityUpdateService.update(entity, with: item, transaction: transaction)
                    }, completion: { _ in
                        let entity = CoreStore.fetchOne(From<ProductVariantEntity>())
                        
                        expect(entity?.id.value) == item.id
                        expect(entity?.price.value) == NSDecimalNumber(decimal: item.price ?? Decimal())
                        expect(entity?.title.value) == item.title
                        expect(entity?.available.value) == item.available
                        expect(entity?.productId.value) == item.productId
                        expect(entity?.selectedOptions.value.first?.name.value) == variantOption.name
                        expect(entity?.image.value?.id.value) == image.id
                        
                        done()
                    })
                }
            }
        }
        
        afterEach {
            _ = try? CoreStore.perform(synchronous: { transaction in
                transaction.deleteAll(From<ProductVariantEntity>())
            })
        }
    }
}