#pragma once

#include "Mellow/Base/Layer.h"
#include "Mellow/Events/MouseEvent.h"
#include "Mellow/Events/KeyEvent.h"

#include "Mellow/Controllers/CameraController.h"

#include "Mellow/Renderer/Renderer.h"
#include "Mellow/Renderer/Shader.h"

// Mesh
#include "Mellow/Renderer/Geometry/Mesh.h"

struct CameraToggleCallbackParams
{
	bool CurrentToggleState;
};

using namespace Mellow;

class MyLayer : public Layer {

	bool OnMouseMovement(MouseMovedEvent& e);
	bool OnKeyPress(KeyPressedEvent& e);

public:
	MyLayer();

	void OnAttach() override;
	void OnDetach() override;
	void OnEvent(Event& e) override;
	void OnUpdate(Timestep ts) override;
	void OnImGuiRender() override;

private:

	CameraController m_CameraController;
	CameraToggleCallbackParams m_CamToggleParams = { false, };

	// Shader
	ShaderLibrary m_ShaderLib;

	// Ground Plane
	Ref<Mesh> m_FloorPlaneMesh;

};