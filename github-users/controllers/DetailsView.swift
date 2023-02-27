import SwiftUI

struct DetailsView: View {
    
    @ObservedObject var viewModel: UserViewModel
    
    @State private var text = ""
    
    var body: some View {
        VStack {
            Group {
                Image(uiImage: UIImage(data: viewModel.selectedUser.avatar ?? Data()) ?? UIImage())
                    .resizable()
                    .frame(width: 100, height: 100)
                HStack {
                    Text("Followers: \(viewModel.selectedUser.followers)")
                    Spacer()
                        .frame(width: 55)
                    Text("Followers: \(viewModel.selectedUser.following)")
                    
                }
            }
            Group {
                VStack(spacing: 10) {
                    Text("Name: \(viewModel.selectedUser.name ?? "")")
                        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
                    Text("Company: \(viewModel.selectedUser.company ?? "")")
                        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
                    Text("Blog: \(viewModel.selectedUser.blog ?? "")")
                        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
                .padding(.leading, 10)
            }
            .border(.black)
            Text("Notes:")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
            TextEditor(text: $text)
                .foregroundColor(.black)
                .border(.black)
                .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
            
            Button("Save") {
                if !text.isEmpty {
                    self.viewModel.saveNote(text: text)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            
            Spacer()
        }
        .onAppear {
            viewModel.getUser()
            self.text = viewModel.selectedUser.notes ?? ""
            
        }
    }
}

//struct DetailsView_Previews: PreviewProvider {
//
//    @State static var userId = 1
//
//    static var previews: some View {
//        DetailsView(userId: $userId)
//    }
//}
