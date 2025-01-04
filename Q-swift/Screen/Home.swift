//
//  Home.swift
//  Q-swift
//
//  Created by Kehinde Bankole on 01/01/2025.
//

import SwiftUI
import Combine

struct Home: View {
    @StateObject private var viewModel = CharacterViewModel<CharactersResponse>()
    @State private var character: Character? = nil
    @Namespace private var characterViewNameSpace
    @State private var currentPage = 1
    @State var myData : [Character] = [];
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            
            VStack {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 2)) {
                    if let availableData = viewModel.data {
                        ForEach(availableData.results) { item in
                            Button(action: {
                                
                                withAnimation(pageChangeAnimation) {
                                    character = item
                                }
                            }) {
                                GeometryReader {
                                    let size = $0.size
                                    ZStack {
                                        AsyncCachedImage(url: URL(string: item.image)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: size.width)
                                                .cornerRadius(20)
                                                .matchedGeometryEffect(id: item.id, in: characterViewNameSpace)
                                        } placeholder: {
                                            VStack {}
                                                .frame(maxWidth: .infinity)
                                                .hidden()
                                                .frame(height: 220)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(.green.gradient)
                                                }
                                        }
                                        
                                        Text(item.name)
                                    }
                                    .onAppear {
                                        // Trigger fetch when the last item is about to appear
                                        if item.id == availableData.results.last?.id {
                                            loadNextPage()
                                        }
                                    }
                                }
                                .frame(height: 220)
                            }
                        }
                    }
                }
                .padding()
                
                
                if viewModel.isLoading && viewModel.data != nil {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                
                
            }
        }
        .overlay {
            if let id = character?.id {
                CharacterView(character: $character)
                    .matchedGeometryEffect(id: id, in: characterViewNameSpace)
                    .transition(.opacity.animation(.easeOut(duration: 0.1)))
            }
        }
        .padding(.vertical)
        .ignoresSafeArea(SafeAreaRegions.all, edges: .bottom)
        .onAppear {
            fetchCharacters()
        }
    }

    func loadNextPage() {
        guard !viewModel.isLoading && currentPage != viewModel.data?.info.pages else { return }
        currentPage += 1
        fetchCharacters()
        print(currentPage)
    }

    func fetchCharacters() {
        let url = "https://rickandmortyapi.com/api/character?page=\(currentPage)"
        viewModel.fetchData(from: url, method: .get)
        
    }
}

#Preview {
    Home()
}

