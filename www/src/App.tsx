import { useState } from "react";
import reactLogo from "./assets/react.svg";
import viteLogo from "/vite.svg";
import "./App.css";
import { Link } from "react-router-dom";

import "@blocknote/core/fonts/inter.css";
import { useCreateBlockNote } from "@blocknote/react";
import { BlockNoteView } from "@blocknote/mantine";
import "@blocknote/mantine/style.css";

export function Editor() {
  const editor = useCreateBlockNote();
  const [title, setTitle] = useState("Untitled");
  const [markdown, setMarkdown] = useState<string>("");

  const onChange = async () => {
    const markdown = await editor.blocksToMarkdownLossy(editor.document);
    setMarkdown(markdown);
  };
 
  return (
    <>
      <div class="top-0 right-0 flex p-4 justify-between">
        <div class="w-full">
          <input class="text-4xl font-bold text-gray-800" value={title} 
	    onChange={(e) => setTitle(e.target.value)}
	  />
        </div>
      </div>
      <BlockNoteView
        editor={editor}
        sideMenu={false}
        theme={"light"}
        className="w-full pl-4 pt-4"
	onChange={onChange}
      />
    </>
  );
}

function App() {
  const [count, setCount] = useState(0);

  return (
    <>
      <div class="fixed top-0 right-0 flex p-4">
        <Link to="/editor" class="p-2 bg-gray-800 text-white rounded-lg">
          Editor
        </Link>
        <a></a>
      </div>
      <div class="p-4 w-full">
        <h1 class="text-4xl font-bold text-gray-800">Home</h1>
        <div class="py-4">
          <input
            class="w-full p-2 rounded-lg border border-gray-300"
            type="text"
            placeholder="Search"
          />
          <ul class="py-4 flex flex-col space-y-2">
            <li class="border border-gray-100 p-2 rounded-lg">Item 1</li>
            <li class="border border-gray-100 p-2 rounded-lg">Item 2</li>
          </ul>
        </div>
        <div class="py-4 w-full">
          <h1 class="text-4xl font-bold text-gray-800">Images</h1>
          <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 py-4">
            {Array.from({ length: 10 }).map((_, i) => (
              <div class="relative">
                <img
                  class="w-full h-48 object-cover rounded-lg"
                  src={`https://picsum.photos/seed/${i}/200/300`}
                  alt=""
                />
                <div class="absolute bottom-0 left-0 right-0 p-2 bg-gray-800 bg-opacity-50 text-white">
                  Image ${i}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}

export default App;
