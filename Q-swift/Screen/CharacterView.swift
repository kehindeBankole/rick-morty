import SwiftUI

struct CharacterView: View {
    @Binding var character: Character?
    
    var body: some View {
        
        if let availableCharacter = character {
            
            ScrollView(showsIndicators: false){
                VStack{
                    ZStack(alignment: .topTrailing){
                        AsyncCachedImage(url: URL(string: availableCharacter.image)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: UIScreen.main.bounds.height / 2)
                        .overlay(content: {
                            LinearGradient(colors: [
                                .clear,
                                .clear,
                                .clear,
                                .white.opacity(0.1),
                                .white.opacity(0.5),
                                .white.opacity(0.9),
                                .white
                            ], startPoint: .top, endPoint: .bottom)
                            .opacity(1)
                        })
                        .clipShape(.rect(cornerRadius: 0))
                        
                        Button(action: {
                            withAnimation(pageChangeAnimation) {
                                character = nil
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.white)
                        }.padding()
                        
                    }
                    Text(availableCharacter.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                }
                
            }
            
            .background(.white.gradient)
            .frame(maxWidth: .infinity)
            .transition(.opacity.animation(.easeOut(duration: 0.1)))
        }
    }
}
