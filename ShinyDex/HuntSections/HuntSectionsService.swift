//
//  HuntSectionsService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 24/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class HuntSectionsService
{
	fileprivate var huntSectionsRepository = HuntSectionsRepository()

	func get() -> HuntSections
	{
		let huntSections = huntSectionsRepository.get()
		return huntSections
	}

	func save(_ huntSections: HuntSections)
	{
		huntSectionsRepository.save(huntSections)
	}
}
