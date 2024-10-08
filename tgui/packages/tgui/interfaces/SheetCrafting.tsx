/**
 * @file
 * @copyright 2022
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { Button, Image, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type SheetCraftingData = {
  availableAmount: number;
  labeledAvailableAmount: string;
  itemList: SheetItem[];
};

type SheetItem = {
  recipeID: number;
  name: string;
  sheetCost: number;
  itemYield: number;
  img: string;
};

export const SheetCrafting = (_props) => {
  const { data } = useBackend<SheetCraftingData>();
  const { availableAmount, labeledAvailableAmount, itemList } = data;

  return (
    <Window width={360} height={760}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow={1}>
            <Section title="Recipes" fill scrollable>
              {itemList.map((item) => {
                return (
                  <Recipe
                    key={item.recipeID}
                    item={item}
                    disabled={availableAmount < item.sheetCost}
                  />
                );
              })}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Amount Left">{labeledAvailableAmount}</Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Recipe = (props: { item: SheetItem; disabled: boolean }) => {
  const { act } = useBackend();
  const { recipeID, name, sheetCost, itemYield, img } = props.item;

  return (
    <Button
      disabled={props.disabled}
      fluid
      onClick={() => act('make', { recipeID })}
      m="0.5rem"
    >
      <Image
        verticalAlign="middle"
        my="0.2rem"
        mr="0.5rem"
        height="32px"
        width="32px"
        src={`data:image/png;base64,${img}`}
      />
      {itemYield > 1 ? <em>{itemYield}x </em> : null}
      {name}
      {sheetCost > 1 ? <em> ({sheetCost} sheets)</em> : null}
    </Button>
  );
};
