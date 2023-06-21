#include "MyLayer.h"

#include <Mellow/Base/Input.h>

#include <imgui.h>

MyLayer::MyLayer() : Layer("MyLayer"), m_CameraController(1280.0f / 720.0f, glm::vec3(0.0f, 0.0f, 2.0f)) {}

void CameraToggleCallback(void* params)
{
	CameraToggleCallbackParams* stateInfo = (CameraToggleCallbackParams*)params;

	if (stateInfo->CurrentToggleState)
	{
		Mellow::Input::SetMouseDisabled();
		return;
	}
	Mellow::Input::SetMouseNormal();
}

void MyLayer::OnAttach() {
	// Make sure that the Render commands work
	RenderCommand::SetClearColor(glm::vec4(0.1, 0.1, 0.12, 1.0));

	// Shader
	m_ShaderLib.Load("res/shaders/floor plane.shader");

	// Camera Settings
	m_CameraController.SetMouseSensitivity(0.7f);
	// Set active state callback function.
	m_CameraController.BindActiveStateCallback(CameraToggleCallback);
	m_CameraController.SetActiveStateCallbackParameterPtr(&m_CamToggleParams);
	m_CameraController.SetActiveState(m_CamToggleParams.CurrentToggleState);

	// Set up the floor mesh
	float vertices[] =
	{
		-1.0f, 0.0f,  1.0f, 0.0f, 0.0f,
		 1.0f, 0.0f,  1.0f, 1.0f, 0.0f,
		 1.0f, 0.0f, -1.0f, 1.0f, 1.0f,
		-1.0f, 0.0f, -1.0f, 0.0f, 1.0f,
	};
	uint32_t indices[] =
	{
		0, 1, 2,
		2, 3, 0,
	};
	m_FloorPlaneMesh = CreateRef<Mesh>("floorPlane", vertices, sizeof(vertices), indices, sizeof(indices),
		VertexLayout({
			{"aPosition", DataType::Vec3},
			{"aTexCoord", DataType::Vec2}
		})
	);
	// Transform
	m_FloorPlaneMesh->SetTransform({
		glm::vec3(0.0f, -1.0f, 0.0f),
		glm::vec3(0.0f),
		glm::vec3(10.0f),
	});

}

bool MyLayer::OnMouseMovement(MouseMovedEvent& e) {
	m_CameraController.OnMouseMovement(e);

	return false;
}

bool MyLayer::OnKeyPress(KeyPressedEvent& e) {

	if (e.GetKeyCode() == Mellow::Key::Escape)
	{
		m_CamToggleParams.CurrentToggleState = !m_CamToggleParams.CurrentToggleState;
		m_CameraController.SetActiveState(m_CamToggleParams.CurrentToggleState);
	}

	return true;
}

void MyLayer::OnDetach() {
	// Do nothing I guess.
}

void MyLayer::OnEvent(Event& e) {
	EventDispatcher dispatcher(e);
	// Dispatch event callbacks for camera controls
	dispatcher.Dispatch<MouseMovedEvent>(MW_BIND_EVENT_FN(MyLayer::OnMouseMovement));
	dispatcher.Dispatch<KeyPressedEvent>(MW_BIND_EVENT_FN(MyLayer::OnKeyPress));
}

void MyLayer::OnUpdate(Timestep ts) {

	m_CameraController.CheckInputs();
	m_CameraController.Update(ts);

	Ref<Shader>& shader = m_ShaderLib.Get("floor plane");
	shader->Use();
	shader->SetVec3("uCameraPos", m_CameraController.GetCamera()->GetPosition());

	shader->SetMat4("uProjectionMatrix", m_CameraController.GetCamera()->GetProjectionMatrixPerspective());
	shader->SetMat4("uViewMatrix", m_CameraController.GetCamera()->GetViewMatrix());

	shader->SetMat4("uModelMatrix", m_FloorPlaneMesh->GetModelMatrix());
	RenderCommand::DrawIndexed(m_FloorPlaneMesh->GetVAO());
}

void MyLayer::OnImGuiRender()
{
	ImGui::Begin("Uniform Window");
	if (ImGui::BeginTabBar("Shader Tabs I Guess"))
	{
		if (ImGui::BeginTabItem("A"))
		{
			ImGui::Text("There's something \nimportant in the \nother tab that \nyou should see...");
			ImGui::EndTabItem();
		}
		if(ImGui::BeginTabItem("B"))
		{
			ImGui::Text("Pranked");
			ImGui::EndTabItem();
		}
		ImGui::EndTabBar();
	}
	ImGui::End();
}
