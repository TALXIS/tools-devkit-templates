import { Card, CardHeader, makeStyles, Text, Title1, tokens } from '@fluentui/react-components';
import type { GeneratedComponentProps } from './RuntimeTypes';

const useStyles = makeStyles({
  container: {
    display: 'flex',
    flexDirection: 'column',
    gap: tokens.spacingVerticalL,
    padding: tokens.spacingHorizontalXL
  }
});

export default function GenPage(props: GeneratedComponentProps) {
  const styles = useStyles();
  const recordId = props.pageInput.recordId;

  return (
    <main className={styles.container}>
      <Title1>__project-name__</Title1>
      <Card>
        <CardHeader header={<Text weight="semibold">Getting started</Text>} />
        <Text>
          Edit __project-name__.tsx to build this GenPage. Add another *.tsx file at the project root to create another page.
        </Text>
        {recordId ? <Text size={200}>Record context: {recordId}</Text> : null}
      </Card>
    </main>
  );
}
