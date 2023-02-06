//
//  NavigationTitleSampelApp.swift
//  NavigationTitleSampel
//
//  Created by Ian Dundas on 06/02/2023.
//

import SwiftUI
import Combine
import SwiftUINavigation

// MARK: - Model -

struct Item: Equatable, Identifiable, Hashable {
	let id = UUID()
	let title: String
}

// MARK: - Basic SwiftUI example with working title animation :

@main
struct NavigationTitleSampelApp: App {

	let items: [Item] = [Item(title: "Item")]

	var body: some Scene {
		WindowGroup {
			NavigationStack {
				List(items) { item in
					NavigationLink(item.title, value: item)
				}
				.navigationTitle("Root")
				.navigationDestination(for: Item.self) { item in
					Text("Subview for \(item.title)")
						.navigationTitle("Navigation Title")
				}
			}
		}
	}
}

// MARK: - Basic SwiftUINavigation example with broken title animation :
// TODO: Uncomment me

//@main
//struct NavigationTitleSampleApp: App {
//
//	let itemRowViewModels: [ItemRowViewModel] = [
//		ItemRowViewModel(item: .init(title: "Item"))
//	]
//
//	var body: some Scene {
//		WindowGroup {
//			NavigationStack {
//				ItemListView(viewModel: ItemListViewModel(itemRowViewModels: itemRowViewModels))
//					.navigationTitle("Root")
//			}
//		}
//	}
//}


// MARK: - Item List -

class ItemListViewModel: ObservableObject {
	@Published var itemRowViewModels: [ItemRowViewModel]

	init(itemRowViewModels: [ItemRowViewModel] = []) {
		self.itemRowViewModels = itemRowViewModels
	}
}

struct ItemListView: View {
	@ObservedObject var viewModel: ItemListViewModel
	
	init(viewModel: ItemListViewModel) {
		self.viewModel = viewModel
	}
	
	var body: some View {
		
		List {
			ItemRowView(viewModel: self.viewModel.itemRowViewModels[0])
		}
	}
}

// MARK: - Item Row -

class ItemRowViewModel: ObservableObject, Identifiable  {
	@Published var item: Item
	@Published var route: Route?
	
	var id: Item.ID { item.id }
	
	enum Route {
		case edit(EditItemViewModel)
	}
	
	init(item: Item) {
		self.item = item
	}
	
	func userTappedRow() {
		self.route = .edit(EditItemViewModel(item: self.item))
	}
}

struct ItemRowView: View {
	
	@ObservedObject var viewModel: ItemRowViewModel
	
	init(viewModel: ItemRowViewModel) {
		self.viewModel = viewModel
	}
	
	var body: some View {
	
		// This works:
//		NavigationLink(value: viewModel.item) {
//			Text(viewModel.item.title)
//		}
//		.navigationDestination(for: Item.self) { item in
//			EditItemView(viewModel: .init(item: item))
//				.navigationTitle("Navigation Title")
//		}
		
		// This doesn't:   :(
				
		Button {
			viewModel.userTappedRow()
		} label: {
			Text(viewModel.item.title)
		}
		.buttonStyle(.borderless)
		.navigationDestination(
			unwrapping: $viewModel.route,
			case: /ItemRowViewModel.Route.edit,
			destination: { $editDayViewModel in

				EditItemView(viewModel: editDayViewModel)
					.navigationTitle("Navigation Title")
			}
		)
	}
}

// MARK: - Edit Item -

class EditItemViewModel: Identifiable, ObservableObject {
	var id: Item.ID { item.id }
	@Published var item: Item
	
	init(item: Item) {
		self.item = item
	}
}

struct EditItemView: View {
	@ObservedObject var viewModel: EditItemViewModel
	
	init(viewModel: EditItemViewModel) {
		self.viewModel = viewModel
	}
	
	var body: some View {
		Text(viewModel.item.title)
	}
}
