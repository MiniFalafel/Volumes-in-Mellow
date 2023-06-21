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
	m_ShaderLib.Load("res/shaders/volume.shader");

	// Camera Settings
	m_CameraController.SetMouseSensitivity(0.7f);
	// Set active state callback function.
	m_CameraController.BindActiveStateCallback(CameraToggleCallback);
	m_CameraController.SetActiveStateCallbackParameterPtr(&m_CamToggleParams);
	m_CameraController.SetActiveState(m_CamToggleParams.CurrentToggleState);

	// Set up the floor mesh
	float vertices[] =
	{
		-1.0f, 0.0f,  1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f,
		 1.0f, 0.0f,  1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f,
		 1.0f, 0.0f, -1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f,
		-1.0f, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f,
	};
	uint32_t indices[] =
	{
		0, 1, 2,
		2, 3, 0,
	};
	m_FloorPlaneMesh = CreateRef<Mesh>("floorPlane", vertices, sizeof(vertices), indices, sizeof(indices),
		VertexLayout({
			{"aPosition", DataType::Vec3},
			{"aTexCoord", DataType::Vec2},
			{"aNormal", DataType::Vec3},
		})
	);
	// Transform
	m_FloorPlaneT = {
		glm::vec3(0.0f, -1.0f, 0.0f),
		glm::vec3(0.0f),
		glm::vec3(10.0f),
	};
	m_FloorPlaneMesh->SetTransform(m_FloorPlaneT);
	// Floor textures
	m_FloorTextureAlbedo = Texture2D::Create("res/textures/Substance_Graph_BaseColor.jpg");
	m_FloorTextureRoughness = Texture2D::Create("res/textures/Substance_Graph_Roughness.jpg");
	m_FloorTextureNormal = Texture2D::Create("res/textures/Substance_Graph_Normal.jpg");

	// Volume
	m_Volume = CreateRef<VolumeCube>(glm::vec3(-0.5f), glm::vec3(0.5f));

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

	m_FloorPlaneMesh->SetTransform(m_FloorPlaneT);

	m_CameraController.CheckInputs();
	m_CameraController.Update(ts);

	{
		Ref<Shader>& shader = m_ShaderLib.Get("floor plane");
		shader->Use();
		shader->SetVec3("uCameraPos", m_CameraController.GetCamera()->GetPosition());

		shader->SetMat4("uProjectionMatrix", m_CameraController.GetCamera()->GetProjectionMatrixPerspective());
		shader->SetMat4("uViewMatrix", m_CameraController.GetCamera()->GetViewMatrix());

		// Bind textures
		m_FloorTextureAlbedo->Bind(1);
		m_FloorTextureRoughness->Bind(2);
		m_FloorTextureNormal->Bind(3);
		shader->SetInt("uBaseTexture", 1);
		shader->SetInt("uRoughnessTexture", 2);
		shader->SetInt("uNormalTexture", 3);
		shader->SetFloat("uTextureSampleSize", m_FloorTextureScale);
		// Light Uniforms
		shader->SetVec3("uLightPos", m_PointLight.Position);
		shader->SetVec3("uLightColor", m_PointLight.Color);
		shader->SetFloat("uLightPower", m_PointLight.Power);

		// Draw floor plane
		shader->SetMat4("uModelMatrix", m_FloorPlaneMesh->GetModelMatrix());
		RenderCommand::DrawIndexed(m_FloorPlaneMesh->GetVAO());
	}

	{
		Ref<Shader>& shader = m_ShaderLib.Get("volume");
		shader->Use();
		shader->SetVec3("uCameraPos", m_CameraController.GetCamera()->GetPosition());
		// matrices
		shader->SetMat4("uProjectionMatrix", m_CameraController.GetCamera()->GetProjectionMatrixPerspective());
		shader->SetMat4("uViewMatrix", m_CameraController.GetCamera()->GetViewMatrix());
		shader->SetMat4("uModelMatrix", m_Volume->GetModelMatrix());

		// Draw the volume cube mesh
		RenderCommand::DrawIndexed(m_Volume->GetMesh()->GetVAO());
	}
}

void MyLayer::OnImGuiRender()
{
	ImGui::Begin("Uniform Window");
	if (ImGui::BeginTabBar("Shader Tabs I Guess"))
	{
		if (ImGui::BeginTabItem("Ground Plane"))
		{
			ImGui::Text("Texture Scale");
			ImGui::SliderFloat("Sc.", &m_FloorTextureScale, 0.01f, 20.0f, "%.3f", ImGuiSliderFlags_Logarithmic);
			ImGui::Text("Plane Rotation");
			ImGui::SliderFloat3("Rot.", &m_FloorPlaneT.Rotation[0], -180.0f, 180.0f); // To test if normals correct themselves.
			ImGui::EndTabItem();
		}
		if(ImGui::BeginTabItem("Point Light"))
		{
			ImGui::Text("Position");
			ImGui::SliderFloat3("Pos", &m_PointLight.Position[0], -5.0f, 5.0f);
			ImGui::Text("Color");
			ImGui::ColorPicker3("Col", &m_PointLight.Color[0]);
			ImGui::Text("Power");
			ImGui::SliderFloat("Pow", &m_PointLight.Power, 0.0f, 20.0f);
			ImGui::EndTabItem();
		}
		ImGui::EndTabBar();
	}
	ImGui::End();
}

VolumeCube::VolumeCube(glm::vec3 min, glm::vec3 max)
	: m_Min(min), m_Max(max)
{
	float vertices[] =
	{
		min[0], min[1], min[2],
		max[0], min[1], min[2],
		max[0], min[1], max[2],
		min[0], min[1], max[2],
		min[0], max[1], min[2],
		max[0], max[1], min[2],
		max[0], max[1], max[2],
		min[0], max[1], max[2],
	};

	uint32_t indices[] =
	{
		0, 1, 2,
		2, 3, 0,

		0, 1, 5,
		5, 4, 0,

		1, 2, 6,
		6, 5, 1,

		2, 3, 7,
		7, 6, 2,

		3, 0, 4,
		4, 7, 3,

		4, 5, 6,
		6, 7, 4,
	};

	m_Mesh = CreateRef<Mesh>("hadn't thought this far yet", vertices, sizeof(vertices), indices, sizeof(indices),
		VertexLayout({
			{"aPosition", DataType::Vec3},
		})
	);
}

glm::mat4 VolumeCube::GetModelMatrix()
{
	return m_Transform.GetModelMatrix();
}
